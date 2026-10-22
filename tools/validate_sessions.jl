# PlutoSliderServer 1.9.0 does not fail exports merely because cells errored.
function validate_sessions(context)
    isempty(context.notebook_sessions) && error("No notebooks discovered")
    failures = String[]
    for session in context.notebook_sessions
        session.run === nothing && error("Notebook did not run: $(session.path)")
        results = session.run.original_state["cell_results"]
        errors = filter(pair -> get(last(pair), "errored", false), collect(results))
        for (id, result) in errors
            body = result["output"]["body"]
            @error "Notebook cell failed" notebook=session.path cell=id message=(body isa AbstractDict ? get(body, :msg, body) : body)
        end
        isempty(errors) || push!(failures, "$(session.path): $(length(errors)) failed cells")
        if hasproperty(session.run, :notebook)
            session.run.notebook.nbpkg_ctx === nothing || error("Private environment: $(session.path)")
        end
        isempty(errors) && println("PASS: ", session.path, " (", length(results), " cells)")
    end
    isempty(failures) || error(join(failures, "; "))
end
