module RichardsonLucyCPU
using FFTW
export rl_cpu

function rl_cpu(vol, psf, iterations)
    vol32 = Float32.(vol)
    psf32 = Float32.(psf)
    psf32 ./= sum(psf32)

    psf_padded = zeros(Float32, size(vol32))
    sx, sy, sz = size(psf32)
    
    # Place PSF in the corner, then circular shift the peak exactly to (1,1,1)
    psf_padded[1:sx, 1:sy, 1:sz] .= psf32
    psf_shifted = circshift(psf_padded, (-(sx÷2), -(sy÷2), -(sz÷2)))

    OTF = fft(psf_shifted)
    OTF_conj = conj.(OTF)

    estimate = copy(vol32)
    eps_val = 1f-7

    for i in 1:iterations
        est_fft = fft(estimate)
        blurred = real.(ifft(est_fft .* OTF))
        ratio = vol32 ./ (blurred .+ eps_val)
        ratio_fft = fft(ratio)
        correction = real.(ifft(ratio_fft .* OTF_conj))
        estimate .*= correction
    end

    return estimate
end
end