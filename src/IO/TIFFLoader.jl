module TIFFLoader
using FileIO
using Images
export load_tiff
function load_tiff(file)
    img = load(file)
    img4d = reshape(img, 1024, 1024, 3, 39)
    return img4d
end
end