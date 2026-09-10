# Use the same environment as CI, independent of the container working directory.
import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using Pluto, PlutoSliderServer, PlutoUI, HypertextLiteral

# Fail clearly if a mounted environment restores old package versions.
@assert VERSION == v"1.12.7" "Expected Julia 1.12.7; pull and recreate the updated container."
@assert pkgversion(Pluto) == v"1.0.3" "Expected Pluto 1.0.3; check mounted environments."
@assert pkgversion(PlutoSliderServer) == v"1.9.0" "Expected PlutoSliderServer 1.9.0; check mounted environments."
println("Julia ", VERSION, "; Pluto ", pkgversion(Pluto),
    "; PlutoSliderServer ", pkgversion(PlutoSliderServer),
    "; PlutoUI ", pkgversion(PlutoUI), "; HypertextLiteral ", pkgversion(HypertextLiteral))
flush(stdout)

PlutoSliderServer.run_directory(
    normpath(joinpath(@__DIR__, "..", "notebooks"));
    SliderServer_port=1234,
    SliderServer_host="0.0.0.0",
)
