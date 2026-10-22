include("runtime.jl")
using Pluto, PlutoSliderServer
include(joinpath(REPO_ROOT, "tools", "validate_sessions.jl"))
println("Julia ", VERSION, "; Pluto ", pkgversion(Pluto), "; PlutoSliderServer ", pkgversion(PlutoSliderServer))
ready_file = get(ENV, "PLUTO_READY_FILE", "")
isempty(ready_file) || rm(ready_file; force=true)
function ready(context)
    validate_sessions(context)
    isempty(ready_file) || write(ready_file, "ready")
end
PlutoSliderServer.run_directory(joinpath(REPO_ROOT, "notebooks");
    SliderServer_port=parse(Int, get(ENV, "PLUTO_PORT", "1234")),
    SliderServer_host=get(ENV, "PLUTO_HOST", "127.0.0.1"),
    SliderServer_watch_dir=false,
    Export_number_of_parallel_tasks=1,
    Export_offer_binder=false,
    on_ready=ready,
)
