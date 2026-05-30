module AlgorithmManager
using ..DeconvOptimCPU
using ..RichardsonLucyCPU
export run_algorithm
function run_algorithm(alg, vol, psf, iterations)
    if alg == "DeconvOptim"
        return run_deconvoptim(vol, psf, iterations)
    elseif alg == "RichardsonLucy"
        return rl_cpu(vol, psf, iterations)
    end
end
end