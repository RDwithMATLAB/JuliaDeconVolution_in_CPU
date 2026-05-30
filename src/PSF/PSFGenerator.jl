module PSFGenerator
using PointSpreadFunctions
export build_psf
function build_psf(wavelength, NA, RI, xy, zstep, psfsize, zsize)
    pp = PSFParams(wavelength, NA, RI)
    p = psf((psfsize, psfsize, zsize), pp; sampling=(xy, xy, zstep))
    p_arr = collect(p) 
    return Float32.(p_arr ./ sum(p_arr))
end
end