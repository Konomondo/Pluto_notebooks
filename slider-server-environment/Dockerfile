# Runtime for the interactive Pluto notebooks. Keep Julia aligned with deploy.yaml.
FROM julia:1.12.7

EXPOSE 1234
RUN apt-get update && apt-get install -y --no-install-recommends unzip && rm -rf /var/lib/apt/lists/*
RUN useradd -ms /bin/bash pluto
WORKDIR /home/pluto
USER pluto

ENV JULIA_PROJECT="/home/pluto/slider-server-environment"

# Cache package installation independently of notebook edits.
COPY --chown=pluto slider-server-environment/Project.toml ./slider-server-environment/Project.toml
RUN julia --project="./slider-server-environment" -e 'import Pkg; Pkg.instantiate(); Pkg.precompile(); using Pluto, PlutoSliderServer, PlutoUI, HypertextLiteral; Pkg.status()'

COPY --chown=pluto . /home/pluto/
CMD ["julia", "--project=/home/pluto/slider-server-environment", "/home/pluto/slider-server-environment/run_server.jl"]
