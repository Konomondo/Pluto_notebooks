# Deployment workflow

.github/workflows/deploy.yaml exports notebooks to gh-pages and publishes
ghcr.io/konomondo/pluto-server:latest. All referenced actions use verified Node 24 releases.
The GitHub Pages deploy action uses lowercase token, branch, and folder inputs.

GHCR authentication uses github.actor with secrets.GITHUB_TOKEN. The Docker job has
contents: read and packages: write; it does not require CR_USER or CR_PAT.
The Pages job has contents: write and actions: write for Julia cache cleanup.

If login succeeds but pushing the existing container package is denied:
- Open Konomondo's Packages, pluto-server, Package settings, Manage Actions access.
- Ensure Konomondo/Pluto_notebooks is listed with Write access (or inherits suitable access).
- A source repository label is included in new builds, but this does not itself grant
  permission to overwrite an existing package.

The original log reported rejected registry credentials, separately from deprecated
Node/save-state warnings. Secret expiration, scopes and SSO status were not observable.
No remote secrets or package settings were modified.

Validation: actionlint v1.7.12 passed (external shellcheck/pyflakes disabled),
git diff --check passed, all eight tagged action.yml files verified node24.
A hosted deployment was not triggered; authentication/build success needs the next run.

References:
- https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry
- https://docs.github.com/en/packages/learn-github-packages/configuring-a-packages-access-control-and-visibility
- https://github.blog/changelog/2025-09-19-deprecation-of-node-20-on-github-actions-runners/

Export resolver fix: the temporary export project now pins PlutoSliderServer to v1.9.0.
The former 0.3.2-0.3 requirement forced Pluto <=0.19.47 and failed on Julia 1.13.
Release 1.9.0 declares Pluto 1 and Julia 1.10-or-later compatibility. Its released
source retains github_action and all six export options used here. Verified with
actionlint and whitespace checks; full Julia resolution/export awaits the next CI run.
Reference: https://github.com/JuliaPluto/PlutoSliderServer.jl/blob/v1.9.0/Project.toml

## Live deployment diagnosis and aligned runtime

Public page https://pluto.konomondo.org/number_guessing_game.html returned HTTP 200,
but decoded embedded state reported Package PlutoUI not found in current path in
the imports cell. Nine cells errored and bonds were empty. HTML assets referenced
Pluto 0.17.7 with same-origin slider server; this is not the new CI export.
The .at backend configured in CI did not resolve during the check.

The notebook manifest is Julia 1.12.7 and declares all game dependencies. Preserve it.
CI and Docker now use Julia 1.12.7 and the same slider-server-environment Project.toml,
with exact Pluto 1.0.3 and PlutoSliderServer 1.9.0 compatibility. CI no longer creates
a separate temporary export environment. It exports only notebooks/ into the root
output directory, using https://pluto.konomondo.org as the interactive backend.

Docker installs and verifies Pluto, PlutoSliderServer, PlutoUI and HypertextLiteral
at build time. Its default command now runs run_server.jl directly; that file activates
the explicit project, instantiates packages, checks runtime versions and logs versions.
The old start_pluto.sh is no longer the image default command.

Deployment follow-through: commit/push, wait for successful image build, then pull and
recreate the Portainer container. Check that Portainer has no command override or mounted
old project/source masking the image files. Logs should show Julia 1.12.7, Pluto 1.0.3,
and PlutoSliderServer 1.9.0. No remote containers were changed during diagnosis.

Validation: actionlint, TOML parsing, dependency/version consistency and CRLF passed;
official julia:1.12.7 Docker tag verified for linux/amd64. Local Docker daemon unavailable,
so image build and live notebook recovery remain unverified.


## Shared environment and local verification (2026-10-22; supersedes runtime notes above)

The server project alone did not disable notebook package management. Three active
notebooks still embedded manifests from different Julia versions; `final.jl` had no
explicit environment. Several analyzer imports were absent from the server project,
and no shared lockfile was committed. Earlier successful Actions runs could publish
notebooks with errored cells: PlutoSliderServer 1.9.0 exports such states normally.

All four active notebooks now call `Pkg.activate` directly in their imports cell,
using `../slider-server-environment`. Embedded manifests were removed. Project.toml
contains the union of active notebook dependencies plus server/test dependencies.
The generated Manifest.toml and `.julia-version` pin the resolved package graph and
runtime. Setup/build instantiates once, and runtime does not instantiate notebooks.
Each notebook still uses its own Julia process and imports modules separately.
Archived notebooks are excluded. No user-specific package settings were changed.

A real resolver/precompile failure was reproduced: Symbolics 5.28 / SymbolicUtils 1
selected SciMLOperators 1.30, whose precompile workload failed on Julia 1.12 with
`ComposedOperator not defined` through ConstructionBase 1.5.6. SymbolicUtils 1's
registry compatibility excludes newer ConstructionBase. The tested legacy API set
uses Symbolics 5.10.0, SymbolicUtils 1.4.0, SciMLBase 2.10.0 and SciMLOperators 0.3.12.
Keep the compatibility anchors until deliberately migrating the analyzer's APIs.

The analyzer's standalone `eval(func)` also had hidden dependencies: Pluto could
run it before symbolic `x` and `b` existed. The cell now references both explicitly.

`tools/setup.jl` enforces the central runtime, instantiates without lockfile drift
and precompiles. `test_notebooks.jl` executes uncached notebooks through a real
local server, checks cell errors/shared worker projects and submits changed widget
values using Pluto's wire protocol. Slider values are indices; Select values are
`puiselect-N`; payload values need `{value: ...}` wrappers. Supply the `explicit`
query parameter for the actual changed bond, or dependency filtering can discard
its value. Initial notebook.bonds is empty before frontend requests; bond names
and co-dependency groups come from the running session's bond_connections.

`export_notebooks.jl` exports to build/site and validates every cell. Binder is
hidden because individual notebook files no longer include their own environment.
The legacy shell entry point forwards to run_server.jl; `.gitattributes` requires
LF for shell scripts. Other edited text uses CRLF.

Actions validates PR/main code, exports only generated files, builds/tests the Linux
image, and publishes only main. Pages publication depends on a successful image
build. Image tags include `latest` and `sha-<full commit>`. Existing GHCR repository
write access and gh-pages Pages settings remain external prerequisites.
Compose binds host loopback, drops capabilities and uses the image's installed
depot. No code/depot mounts or package installation are needed at runtime. The
health marker is written after successful notebook startup validation. Deployment
is manual after CI: pull/recreate the same immutable image tag as the Pages source.
HTML/backend source hashes must match. Serving HTML from the backend avoids the
separate Pages/external-container switch.

Final local verification:
- Julia 1.12.7 / Pluto 1.0.3 / PlutoSliderServer 1.9.0 shared setup and precompile pass;
  a second instantiate preserved the manifest exactly.
- All four notebooks (149 total cells: 12 game, 46 analyzer, 80 finance, 11 final)
  execute without cell errors.
- CI export passes for all four notebooks; exported source bytes match backend input.
- All-notebook integration suite: 25/25 assertions pass, including real changed-value
  HTTP requests for game, analyzer and finance and shared project paths in workers.
- Stateless game: 41/41 Julia assertions pass.
- Chromium widget test passes selection, scoring, loss/win, reset, timeout and retry.
- Chromium against the actual server passes isolated browsers, cache replay,
  six-turn loss, new round and sixth-turn win (16 state requests; no page errors).
- actionlint v1.7.12 and Docker Compose config pass. Official Julia Docker image
  tag 1.12.7-bookworm exists and includes linux/amd64.
- Latest recorded remote deployment workflow was successful:
  https://github.com/Konomondo/Pluto_notebooks/actions/runs/34499296518 .
  This is historical remote evidence, not execution of these new local changes.
- Docker daemon is unavailable on this machine, so actual Linux image build and
  deployment remain unverified. No workflow was triggered or image/site published.
- Public deployment URLs could not be read by the browsing tool in this session;
  older live-site diagnoses above are historical, not a new remote runtime check.

Sources checked (official documentation and released source):
- https://plutojl.org/en/docs/packages-advanced/
- https://github.com/JuliaPluto/Pluto.jl/blob/v1.0.3/src/packages/Packages.jl
- https://github.com/JuliaPluto/Pluto.jl/blob/v1.0.3/src/evaluation/WorkspaceManager.jl
- https://github.com/JuliaPluto/PlutoSliderServer.jl/blob/v1.9.0/src/PlutoSliderServer.jl
- https://github.com/JuliaPluto/PlutoSliderServer.jl/blob/v1.9.0/src/Actions.jl
- https://github.com/JuliaPluto/PlutoSliderServer.jl/blob/v1.9.0/src/HTTPRouter.jl
- https://github.com/JuliaPluto/PlutoUI.jl/blob/v0.7.83/src/Builtins.jl

See README.md for setup/test/serve commands, Compose and Portainer deployment steps.

Local server started successfully on http://127.0.0.1:1234/ with all four notebooks
passing startup validation. It uses the portable runtime and shared repository depot
with the previous workspace depot as a read cache. Reproduce via tools/local.ps1
with the -Julia and -CacheDepot parameters shown in README. Setup without CacheDepot
uses only the repository-local depot and will download missing locked packages.
Logs are under .local/server.log; test evidence is in .local/test-notebooks.log,
shared-setup-final.log, export-notebooks.log, browser-widget.log and browser-server.log.
All edited text files passed CRLF checks; start_pluto.sh intentionally uses LF as
required by the new .gitattributes rule.

Changed files for this continuation:
- Root: .julia-version, .gitignore, .dockerignore, .gitattributes, compose.yaml, README.md.
- .github/workflows/deploy.yaml.
- slider-server-environment: Project.toml, Manifest.toml, Dockerfile, runtime.jl,
  run_server.jl, start_pluto.sh.
- notebooks: all four active .jl notebooks and README.md.
- tools: setup.jl, local.ps1, docker.ps1, validate_sessions.jl, test_notebooks.jl,
  export_notebooks.jl, update_notebook_packages.jl, requirements-test.txt,
  test_number_guessing_game_browser.py and test_number_guessing_game_server.py.
- .claude: continued deployment plan, knowledge/deployment.md, knowledge/INDEX.md,
  knowledge/number-guessing-game.md.


## Restricted analyzer input (2026-10-22)

Superseding the earlier eval dependency workaround: the analyzer now uses the
MathFormulas allowlist interpreter and contains no eval calls. Programming input
is rejected before calculations. Formula unit/symbolic tests pass 153 assertions;
the full notebook/HTTP suite passes 56 assertions, including rejection and recovery.
The CI export also succeeds for all four notebooks. The finance notebook has 79
cells after removal of its forced-white-background cell (148 total notebook cells).
Actions and Docker run the new formula tests. See function-analyzer.md for the
language contract. Actual Docker build remains unverified without a running daemon.

The local server has been restarted with the restricted interpreter and finance
background fix. Chromium confirms math entry, code rejection and graph recovery.
Current runtime log: .local/server-restricted.log.


## Linux Docker verification (2026-10-22)

The user completed the image build. Docker image ID:
sha256:3e1024c319c17250c25622b024c45fd9c5fb84d59eb5b29c4f8bf1caf0aade4e.
This supersedes the earlier unavailable-daemon limitation for local testing.
The version file, shared Project/Manifest, MathFormulas helper, all four active
notebooks and both Julia test scripts match the workspace by SHA-256.
Compose started pluto_notebooks-pluto-1 on 127.0.0.1:1234 after the native workspace
Julia server was verified and stopped. No other containers were modified.
Chromium against the Linux container passes game interactions (16 state requests,
no page errors), independent visitors, cached replay, reset and sixth-turn win.
The analyzer browser test also passes formula entry, code rejection, domain
feedback and graph recovery. Evidence: .local/browser-docker-game.log and
.local/browser-docker-formulas.log. Remaining external steps are push, successful
Actions publication and pulling/recreating the matching image on the self-hosted
server; none of those remote actions were performed here.

Final Docker status: running, healthy; all four notebooks ready with no cell errors.
