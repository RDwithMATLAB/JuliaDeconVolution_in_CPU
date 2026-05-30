module DeconvOptimCPU
using DeconvOptim
export run_deconvoptim
function run_deconvoptim(vol, psf, iterations)
    result, stats = deconvolution(
        vol,
        psf;
        regularizer = x -> 0f0,
        iterations = iterations
    )
    return result
end
end