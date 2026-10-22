import Pkg, TOML
const REPO_ROOT = normpath(joinpath(@__DIR__, ".."))
const REQUIRED_JULIA = VersionNumber(strip(read(joinpath(REPO_ROOT, ".julia-version"), String)))
VERSION == REQUIRED_JULIA || error("Expected Julia $REQUIRED_JULIA, got $VERSION")
Pkg.activate(@__DIR__)
isfile(joinpath(@__DIR__, "Manifest.toml")) || error("Run tools/setup.jl first: shared Manifest.toml is missing")
ENV["GKSwstype"] = "100"
ENV["JULIA_LOAD_PATH"] = "@" * (Sys.iswindows() ? ";" : ":") * "@stdlib"
