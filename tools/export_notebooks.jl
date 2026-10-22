include(joinpath(@__DIR__, "..", "slider-server-environment", "runtime.jl"))
using PlutoSliderServer
include("validate_sessions.jl")
PlutoSliderServer.export_directory(joinpath(REPO_ROOT, "notebooks");
    Export_output_dir=joinpath(REPO_ROOT, "build", "site"),
    Export_number_of_parallel_tasks=1,
    Export_cache_dir=nothing,
    Export_baked_notebookfile=false,
    Export_baked_state=false,
    Export_disable_ui=false,
    Export_offer_binder=false,
    Export_slider_server_url=get(ENV, "PLUTO_PUBLIC_URL", "https://pluto.konomondo.org"),
    on_ready=validate_sessions,
)
