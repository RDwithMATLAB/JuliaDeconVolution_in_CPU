module SystemInfo
export system_summary
function system_summary()
    return string("CPU Threads: ", Threads.nthreads())
end
end