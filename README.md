# Pluto notebooks

All four active notebooks in `notebooks/` use one environment in
`slider-server-environment/Project.toml` and its committed `Manifest.toml`.
`.julia-version` is the single source for the exact Julia runtime. The project
compat entry describes package compatibility; startup checks the exact version file.
Archived notebooks in `_not_used_notebooks/` are not deployed or tested.

Packages are installed and precompiled once by setup or image build. Each Pluto
notebook runs in its own Julia worker and therefore imports packages separately;
sharing an environment does not share live modules or memory between workers.
Every imports cell explicitly calls `Pkg.activate` before its imports. Do not add
`Pkg.instantiate`, `Pkg.add`, or embedded Project/Manifest strings to notebooks.

## Run locally on Windows

Install the Julia version named in `.julia-version`, or pass its executable with
`-Julia`. From this repository:

```powershell
./tools/local.ps1 setup
./tools/local.ps1 test
./tools/local.ps1 serve
```

Open http://127.0.0.1:1234/ after all notebooks are ready. Stop with Ctrl+C.
Setup uses `.local/julia-depot`; logs and generated exports can be kept under
`.local/` and `build/`, which are ignored. The launcher works from any directory.
To use the existing portable runtime and package cache on this machine:

```powershell
./tools/local.ps1 setup -Julia ../.codex/tmp/pluto-site/julia-1.12.7/bin/julia.exe -CacheDepot ../.codex/tmp/pluto-site/julia-depot
./tools/local.ps1 test -Julia ../.codex/tmp/pluto-site/julia-1.12.7/bin/julia.exe -CacheDepot ../.codex/tmp/pluto-site/julia-depot
./tools/local.ps1 serve -Julia ../.codex/tmp/pluto-site/julia-1.12.7/bin/julia.exe -CacheDepot ../.codex/tmp/pluto-site/julia-depot
```

On Linux/macOS, with the matching Julia executable:

```sh
julia --startup-file=no --project=slider-server-environment tools/setup.jl
julia --startup-file=no --project=slider-server-environment tools/test_notebooks.jl
julia --startup-file=no --project=slider-server-environment slider-server-environment/run_server.jl
```

`PLUTO_HOST` defaults to loopback; `PLUTO_PORT` defaults to 1234. Exports are written
by `tools/export_notebooks.jl` to `build/site/`. `PLUTO_PUBLIC_URL` sets the interactive
backend for those exports (default https://pluto.konomondo.org).

The Julia tests execute every notebook without a state cache, fail on cell errors,
check shared environment activation, fetch every exported HTML page and submit real
HTTP slider requests. `tools/test_number_guessing_game.jl` separately tests scoring.
Optional Chromium checks use `tools/requirements-test.txt`; install Playwright's
Chromium with `PLAYWRIGHT_BROWSERS_PATH` set to `.local/browsers`, set
`PLUTO_TEST_JULIA` to the Julia executable, then run
`python tools/test_number_guessing_game_server.py` against the running server.

## Function analyzer input

Enter mathematical formulas using `x`, `b`, `pi` (or the Unicode pi symbol), `e`,
`+ - * / ^`, parentheses, and `sin`, `cos`, `tan`, `exp`, `log`, `sqrt`.
Powers require literal integer exponents from -8 to 8. For example:
`sin(x) + b*x^2`. The **Simplify formula** checkbox starts off: the
LaTeX then follows the entered expression's structure. Enable it to combine and
simplify terms in the displayed formula; calculations are unchanged. Programming syntax is rejected and formulas are limited in size
and complexity. Points outside the real-valued domain are omitted from the graph.

Run the input and symbolic derivative regression tests with:

```sh
julia --startup-file=no --project=slider-server-environment tools/test_math_formulas.jl --symbolic
```

The notebook integration tests also submit accepted/rejected formulas over HTTP.
An optional UI test is `python tools/test_function_analyzer_browser.py` against the
running local server, using the same Playwright setup as the game browser test.

## Maintain packages

Add dependencies to the shared project with Julia Pkg. For deliberate upgrades,
run `tools/update_notebook_packages.jl`, then setup, notebook tests and export.
Review both Project and Manifest. The analyzer currently uses the Symbolics 5.10
API; its SciML compatibility pins avoid a reproduced Julia 1.12 precompile failure.
Changing that API requires testing the analyzer rather than simply widening pins.
For a Julia upgrade, edit `.julia-version`, resolve the manifest with that runtime,
and run the same tests plus the Linux image build. Never hand-edit manifest entries.

## Docker and self-hosted deployment

Docker Desktop must be running with Linux containers. Build and test the image:

```powershell
./tools/docker.ps1 build
./tools/docker.ps1 up
./tools/docker.ps1 logs
```

Linux equivalents (also suitable on the deployment host):

```sh
export JULIA_VERSION="$(tr -d '\r\n' < .julia-version)"
docker compose build
docker compose up -d
```

The image installs from the committed manifest, precompiles as the unprivileged
`pluto` user and runs every notebook plus HTTP tests during the build. Runtime
performs no package installation. The health check becomes ready only after all
notebooks pass cell validation. Port 1234 is bound to host loopback. Put your existing
HTTPS reverse proxy in front of it; a proxy in another container needs a shared
Docker network and upstream `pluto:1234` instead of host loopback. Notebook code can
execute user-supplied expressions, so keep this container isolated, without host
mounts, Docker socket, credentials or unrelated application data.

GitHub Actions validates on pull requests and main pushes, then builds/tests the
Linux amd64 image. Main publishes `latest` and `sha-<full commit>` to
`ghcr.io/konomondo/pluto-server`. Pages publication follows the successful image
build and includes only generated site files. Publishing uses `GITHUB_TOKEN` with
job-scoped permissions. Existing GHCR packages must grant this repository Actions
write access; Pages must serve the `gh-pages` branch.

After reviewing and pushing the changes, wait for the workflow to pass. For an
existing deployment, select the tested `sha-...` tag with `PLUTO_IMAGE_TAG`, then:

```sh
docker compose pull
docker compose up -d --no-build
docker compose logs --tail=100
```

In Portainer use the same image/tag and port, remove old command overrides and
mounts masking `/home/pluto`, then pull and recreate. No package volume is needed:
the image contains the tested depot. Verify container health, all four pages and
slider changes. Keep Pages and the backend on identical notebook source; slider
requests are keyed by notebook hashes. GitHub cannot atomically switch the external
server and Pages: recreate promptly or serve the image's own HTML from the same
backend. Roll back by selecting the previous immutable image tag and matching
Pages revision.

See `.claude/knowledge/deployment.md` for investigation evidence and local results.
