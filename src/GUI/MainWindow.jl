using GLMakie
using FileIO
using Images
using NativeFileDialog

println("Building CPU GUI...")
println("System: ", SystemInfo.system_summary())

const M = GLMakie

current_file = Observable("No file loaded")
raw_volume = Observable(zeros(Float32, 100, 100, 39))
decon_volume = Observable(zeros(Float32, 100, 100, 39))
current_z = Observable(20)
status_text = Observable("Ready")
current_channel = Observable(1)
loaded_img4d = Ref{Any}(nothing)

raw_slice = lift(raw_volume, current_z) do vol, z
    vol[:, :, clamp(z, 1, size(vol, 3))]
end

decon_slice = lift(decon_volume, current_z) do vol, z
    vol[:, :, clamp(z, 1, size(vol, 3))]
end

fig = Figure(size=(1500, 850))
ax1 = M.Axis(fig[1, 1], title="Raw Image")
ax2 = M.Axis(fig[1, 2], title="Deconvolved Image")

heatmap!(ax1, raw_slice, colormap=:grays)
heatmap!(ax2, decon_slice, colormap=:magma)

panel = GridLayout()
fig[1, 3] = panel

Label(panel[1, 1], "3D CPU Deconvolution", font=:bold)

btn_open = Button(panel[2, 1], label="Open TIFF")
menu_channel = Menu(panel[3, 1], options=zip(["Channel 1", "Channel 2", "Channel 3"], 1:3))

slider_z = Slider(panel[4, 1], range=1:100, startvalue=20) # Expanded range just in case
Label(panel[5, 1], lift(z -> "Z Slice: $(z)", slider_z.value))

slider_na = Slider(panel[6, 1], range=1.0:0.01:1.5, startvalue=1.42)
Label(panel[7, 1], lift(v -> "NA: $(round(v, digits=2))", slider_na.value))

slider_ri = Slider(panel[8, 1], range=1.3:0.01:1.6, startvalue=1.515)
Label(panel[9, 1], lift(v -> "RI: $(round(v, digits=3))", slider_ri.value))

slider_xy = Slider(panel[10, 1], range=0.05:0.001:0.2, startvalue=0.107)
Label(panel[11, 1], lift(v -> "XY Pixel Size: $(round(v, digits=3))", slider_xy.value))

slider_zstep = Slider(panel[12, 1], range=0.1:0.01:1.0, startvalue=0.40)
Label(panel[13, 1], lift(v -> "Z Step: $(round(v, digits=2))", slider_zstep.value))

slider_iter = Slider(panel[14, 1], range=5:5:100, startvalue=15)
Label(panel[15, 1], lift(v -> "Iterations: $(v)", slider_iter.value))

menu_psf = Menu(panel[16, 1], options=[("65x65", 65), ("129x129", 129)], default="129x129")

fluor_keys = collect(keys(FluorophoreDB.FLUOR_DB))
menu_fluor = Menu(panel[17, 1], options=fluor_keys, default="TRITC")

menu_alg = Menu(panel[18, 1], options=["RichardsonLucy", "DeconvOptim"], default="RichardsonLucy")

btn_run = Button(panel[19, 1], label="Run CPU Deconvolution")
btn_save = Button(panel[20, 1], label="Save Result")

Label(panel[21, 1], status_text, color=:blue)

connect!(current_z, slider_z.value)

on(btn_open.clicks) do _
    file = pick_file(filterlist="tif;tiff")
    if file === nothing || file == ""
        return
    end
    current_file[] = file
    status_text[] = "Loading TIFF..."
    
    Threads.@spawn begin
        try
            img = load(file)
            nz = size(img, 3) ÷ 3
            img4d = reshape(img, size(img, 1), size(img, 2), 3, nz)
            loaded_img4d[] = img4d
            
            ch = current_channel[]
            vol = Float32.(channelview(img4d[:, :, ch, :]))
            vol .-= minimum(vol)
            mx = maximum(vol)
            if mx > 0
                vol ./= mx
            end
            
            raw_volume[] = vol
            decon_volume[] = zeros(Float32, size(vol))
            
            # Dynamically update Z slider range based on loaded image
            slider_z.range[] = 1:nz
            
            status_text[] = "Loaded $(nz) slices successfully"
        catch e
            status_text[] = "Error loading file! See console."
            println("\n--- ERROR LOADING TIFF ---")
            showerror(stdout, e)
            println("\n--------------------------")
        end
    end
end

on(menu_channel.selection) do ch
    current_channel[] = ch
    loaded_img4d[] === nothing && return
    
    vol = Float32.(channelview(loaded_img4d[][:, :, ch, :]))
    vol .-= minimum(vol)
    mx = maximum(vol)
    if mx > 0
        vol ./= mx
    end
    raw_volume[] = vol
end

on(btn_run.clicks) do _
    if loaded_img4d[] === nothing
        status_text[] = "Load a TIFF first!"
        return
    end
    status_text[] = "Running... (Check console)"
    
    ch = current_channel[]
    vol = Float32.(channelview(loaded_img4d[][:, :, ch, :]))
    vol .-= minimum(vol)
    
    fluor = menu_fluor.selection[]
    alg = menu_alg.selection[]
    wl = FluorophoreDB.FLUOR_DB[fluor]
    na = slider_na.value[]
    ri = slider_ri.value[]
    xy = slider_xy.value[]
    zstep = slider_zstep.value[]
    iters = slider_iter.value[]
    psfsize = menu_psf.selection[]
    
    # Extract the dynamic Z-size
    zsize = size(vol, 3)

    Threads.@spawn begin
        try
            status_text[] = "Generating PSF ($(zsize) slices)..."
            psf_norm = PSFGenerator.build_psf(wl, na, ri, xy, zstep, psfsize, zsize)
            
            status_text[] = "CPU Deconvolution ($(alg))..."
            res = AlgorithmManager.run_algorithm(alg, vol, psf_norm, iters)
            
            res .-= minimum(res)
            mx = maximum(res)
            if mx > 0
                res ./= mx
            end
            
            decon_volume[] = res
            status_text[] = "Finished!"
        catch e
            status_text[] = "Error! See console."
            println("\n--- ERROR DURING DECONVOLUTION ---")
            showerror(stdout, e)
            println("\n----------------------------------")
        end
    end
end

on(btn_save.clicks) do _
    if current_file[] == "No file loaded" || current_file[] == ""
        return
    end
    out = replace(current_file[], ".tif" => "_DECON_CPU_CH$(current_channel[]).tif", ".tiff" => "_DECON_CPU_CH$(current_channel[]).tiff")
    try
        TIFFExporter.save_volume(out, decon_volume[])
        status_text[] = "Saved: " * basename(out)
    catch e
        status_text[] = "Save failed! See console."
        println("\n--- ERROR SAVING TIFF ---")
        showerror(stdout, e)
        println("\n-------------------------")
    end
end

display(fig)