module TIFFExporter
using FileIO
using Images
export save_volume
function save_volume(file, vol)
    save(file, colorview(Gray, vol))
end
end