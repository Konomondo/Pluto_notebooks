include(joinpath(@__DIR__, "..", "slider-server-environment", "runtime.jl"))
using Pluto, PlutoSliderServer, HTTP, Test, Sockets, Dates
include("validate_sessions.jl")
for path in readdir(joinpath(REPO_ROOT, "notebooks"); join=true)
    endswith(path, ".jl") || continue
    source = read(path, String)
    @assert occursin("Pkg.activate", source) "Notebook must activate shared environment: $path"
    @assert !occursin("PLUTO_PROJECT_TOML_CONTENTS", source) "Embedded environment: $path"
end
const OUTPUT = joinpath(REPO_ROOT, "build", "test-export")
wire_value(v) = v isa Date ? string(v) : v isa AbstractRange ? [first(v), last(v)] : ismissing(v) ? nothing : v
function check_ready(context)
    try
        validate_sessions(context)
        port = Int(Sockets.getsockname(context.serversocket)[2])
        base = "http://127.0.0.1:$port"
        for session in context.notebook_sessions
            html = replace(session.path, r"\.jl$" => ".html")
            @test HTTP.get("$base/$html").status == 200
            hasproperty(session.run, :bond_connections) || continue
            notebook = session.run.notebook
            project = Pluto.WorkspaceManager.eval_fetch_in_workspace(
                (context.server_session, notebook), :(Base.active_project()))
            @test realpath(project) == realpath(joinpath(REPO_ROOT, "slider-server-environment", "Project.toml"))
            target = session.path == "function_analyzer.jl" ? :b_val : session.path == "finance_plan.jl" ? :months_to_new_employee : :submitted
            names = session.run.bond_connections[target]
            @test !isempty(names)
            bonds = Dict{String,Any}(string(k) => wire_value(Pluto.WorkspaceManager.eval_fetch_in_workspace(
                (context.server_session, notebook), k)) for k in names)
            changed = if session.path == "function_analyzer.jl"
                bonds["b_val"] = 11 # Slider(0:0.1:10) sends a one-based index.
                :b_val => 1.0
            elseif session.path == "finance_plan.jl"
                bonds["scenario"] = "puiselect-1" # First option maps to scenario 2.
                bonds["months_to_new_employee"] = 6
                :months_to_new_employee => 6
            else
                bonds["submitted"] = Dict("round_id" => "0123456789abcdef", "guesses" => [50], "request_id" => 1)
                :submitted => bonds["submitted"]
            end
            explicit = PlutoSliderServer.base64urlencode(Pluto.pack([string(target)]))
            response = HTTP.post("$base/staterequest/$(session.current_hash)/?explicit=$explicit", [], Pluto.pack(Dict(k => Dict("value" => v) for (k,v) in bonds)))
            @test response.status == 200
            result = Pluto.unpack(response.body)
            @test haskey(result, "patches")
            @test !isempty(result["patches"])
            @test !any(c.errored for c in notebook.cells)
            actual = Pluto.WorkspaceManager.eval_fetch_in_workspace((context.server_session, notebook), first(changed))
            @test actual == last(changed)
            if session.path == "function_analyzer.jl"
                explicit_formula = PlutoSliderServer.base64urlencode(Pluto.pack(["text_equation"]))
                endpoint = "$base/staterequest/$(session.current_hash)/?explicit=$explicit_formula"
                sources = [
                    ("sin(x) + b*x^2", true),
                    ("run(`whoami`)", false),
                    ("Core.eval(Main, x)", false),
                    ("begin x; b end", false),
                    ("read(\"secret\")", false),
                    ("x^1000000", false),
                    ("sqrt(x-1)", true),
                    ("sqrt(-1) + x", true),
                    ("4", true),
                    ("x^2 + b*x", true),
                ]
                for (source, allowed) in sources
                    bonds["text_equation"] = source
                    response = HTTP.post(endpoint, [], Pluto.pack(Dict(k => Dict("value" => v) for (k,v) in bonds)))
                    @test response.status == 200
                    @test !any(c.errored for c in notebook.cells)
                    parsed = Pluto.WorkspaceManager.eval_fetch_in_workspace(
                        (context.server_session, notebook), :(formula_input.message === nothing))
                    @test parsed == allowed
                    if allowed && source == "x^2 + b*x"
                        actual_y = Pluto.WorkspaceManager.eval_fetch_in_workspace(
                            (context.server_session, notebook), :(MathFormulas.plot_value(formula_input.ast, 2, b_val)))
                        @test isapprox(actual_y, 6.0)
                    end
                end
                println("PASS: formula HTTP acceptance, code rejection, real-domain handling and recovery")
            end
            println("PASS: HTTP bonds ", session.path, " ", collect(keys(bonds)))
        end
    finally
        close(context.http_server)
        for notebook in collect(values(context.server_session.notebooks))
            Pluto.SessionActions.shutdown(context.server_session, notebook; async=false)
        end
    end
end
@testset "All notebooks via PlutoSliderServer" begin
    PlutoSliderServer.run_directory(joinpath(REPO_ROOT, "notebooks");
        notebook_paths=isempty(ARGS) ? nothing : ARGS,
        SliderServer_host="127.0.0.1", SliderServer_port=0,
        SliderServer_watch_dir=false, Export_output_dir=OUTPUT,
        Export_cache_dir=nothing, Export_number_of_parallel_tasks=1,
        on_ready=check_ready)
end
