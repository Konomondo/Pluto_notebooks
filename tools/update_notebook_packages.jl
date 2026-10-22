# Deliberate, shared update. Run setup and all tests afterward; review the Manifest.
include(joinpath(@__DIR__, "..", "slider-server-environment", "runtime.jl"))
Pkg.update()
Pkg.precompile()
Pkg.status()
