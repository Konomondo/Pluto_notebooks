import Pkg
root = normpath(joinpath(@__DIR__, ".."))
required = VersionNumber(strip(read(joinpath(root, ".julia-version"), String)))
VERSION == required || error("Expected Julia $required, got $VERSION")
ENV["GKSwstype"] = "100"
Pkg.activate(joinpath(root, "slider-server-environment"))
manifest = joinpath(root, "slider-server-environment", "Manifest.toml")
before = isfile(manifest) ? read(manifest) : nothing
Pkg.instantiate()
before === nothing || read(manifest) == before || error("Instantiation changed Manifest.toml; resolve deliberately and review it")
Pkg.precompile()
Pkg.status()
