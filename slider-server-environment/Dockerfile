# Supply JULIA_VERSION from .julia-version (Compose and Actions do this).
ARG JULIA_VERSION
FROM julia:${JULIA_VERSION}-bookworm
EXPOSE 1234
RUN apt-get update && apt-get install -y --no-install-recommends libxml2 libgl1 libxt6 libxrender1 libxext6 && rm -rf /var/lib/apt/lists/*
RUN useradd -ms /bin/bash pluto
WORKDIR /home/pluto
USER pluto
ENV GKSwstype="100" JULIA_PROJECT="/home/pluto/slider-server-environment" JULIA_LOAD_PATH="@:@stdlib" PLUTO_HOST="0.0.0.0" PLUTO_READY_FILE="/tmp/pluto-ready" JULIA_NUM_THREADS="2"
COPY --chown=pluto .julia-version ./
COPY --chown=pluto slider-server-environment/Project.toml slider-server-environment/Manifest.toml ./slider-server-environment/
COPY --chown=pluto tools/setup.jl ./tools/setup.jl
RUN julia --startup-file=no tools/setup.jl
COPY --chown=pluto slider-server-environment/*.jl ./slider-server-environment/
COPY --chown=pluto tools/validate_sessions.jl tools/test_notebooks.jl tools/test_math_formulas.jl ./tools/
COPY --chown=pluto notebooks/ ./notebooks/
# Exercise Linux native libraries and all notebook cells before publishing the image.
RUN julia --startup-file=no tools/test_math_formulas.jl --symbolic && julia --startup-file=no tools/test_notebooks.jl
HEALTHCHECK --interval=30s --timeout=10s --start-period=15m --retries=3 CMD test -f /tmp/pluto-ready || exit 1
CMD ["julia", "--startup-file=no", "--project=/home/pluto/slider-server-environment", "/home/pluto/slider-server-environment/run_server.jl"]
