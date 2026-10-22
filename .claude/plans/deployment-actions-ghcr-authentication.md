# Deployment action runtime and GHCR authentication repair

Problem: deploy.yaml uses obsolete action releases and GHCR rejects login with CR_USER/CR_PAT.
The supplied log establishes authentication rejection but not the underlying secret problem.

- Upgrade every action to a verified released Node 24 version.
- Migrate GitHub Pages deploy inputs to the current lowercase names.
- Use github.actor and secrets.GITHUB_TOKEN for GHCR, granting packages: write only to build-docker.
- Scope contents: write and actions: write (Julia cache cleanup) to deploy-pages.
- Add Buildx setup and a source repository label; preserve image name and export configuration.
- Validate YAML, action inputs, permissions, and CRLF. Do not publish or trigger deployment.
- Document existing GHCR package access: pluto-server must grant this repository Actions write access.

Verified released versions via GitHub API and tagged action.yml metadata:
checkout v7.0.1, actions/cache v6.1.0, setup-julia v3.0.2, julia cache v3.3.0,
Pages deploy v4.9.0, Docker login v4.6.0, Buildx v4.3.0, build-push v7.3.0.
All eight declare node24.

## Outcome
Implemented and passed actionlint v1.7.12 and git diff --check. All eight final action refs verified against their tagged metadata as Node 24. No deployment triggered. Existing remote package access remains unverified. Operational notes promoted to ../knowledge/deployment.md.

## Export package resolver repair
The next run failed because the temporary export project pins PlutoSliderServer 0.3, forcing Pluto <=0.19.47, incompatible with the Julia 1.13 runner. Replace that obsolete requirement with the verified PlutoSliderServer 1.9.0 release (Pluto 1, Julia >=1.10). Retain the existing export environment structure and settings; verify github_action and all supplied export options against released source, then run actionlint and CRLF checks.

Resolver repair outcome: pinned export dependency to exact v1.9.0. Released API and all six configuration options verified; actionlint and git diff --check passed. Full CI execution remains unverified.

## Live site runtime repair
Fetched the public .org notebook and decoded embedded MessagePack state: initial import fails with Package PlutoUI not found; downstream cells fail and bonds are empty. HTML references Pluto 0.17.7 and same-origin slider server. Docker still uses Julia 1.9; notebook manifest was created with 1.12.7. The workflow's .at backend does not resolve.
Align Docker and CI on Julia 1.12.7 and one server Project.toml with exact Pluto 1.0.3 / PlutoSliderServer 1.9.0 compatibility. Add explicit Julia startup and package/version logging, remove empty root-project setup, and verify imports during image build. Export only active notebooks using the shared environment to the root output folder and point the CI export backend at .org. Preserve notebook manifest and user notebook moves. Validate workflow/TOML/startup statically and attempt container availability; remote rebuild/redeploy remains user-operated.

Live repair outcome: shared versions/project, explicit Julia startup, build-time imports, and .org export endpoint implemented. actionlint, TOML/dependency checks, Docker tag verification and CRLF passed. Local Docker daemon unavailable; rebuilding and verifying remote runtime remains outstanding. Evidence and deployment steps recorded in knowledge/deployment.md.

## Stateless interaction and plotting libraries
Live checks: game binding graph connects submitted and new_game. A real staterequest returns HTTP 200 but a different round ID and zero turns, confirming random regeneration rejects the guess. Both function_analyzer and finance_plan package setup fail because GR libGRM.so cannot find libxml2.so.2; Plots and its Unitful extension fail, then all imports/widgets fail.
Use browser-generated 64-bit round IDs carried in submitted history, derive the Julia secret deterministically from that ID, and make reset only rebuild the grid. Keep scoring in Julia and add a visible recoverable timeout. Pin Docker to verified 1.12.7-bookworm and install libxml2 plus headless GR libraries; set GKSwstype=100 in Docker and CI. Validate browser interactions and pure Julia scoring if a local runtime can be provisioned. Preserve the original analyzer/finance content and user moves.

User explicitly requested local PlutoSliderServer execution. Provisioning portable Julia 1.12.7, matching server packages and Chromium under workspace scratch paths. Isolated notebook copies will be used for real HTTP/browser tests, including cached replays and independent browser rounds.

## Shared notebook environment, local validation and deployment preparation (2026-10-22)

Scope: investigate all four active notebooks, released Pluto/PlutoSliderServer source,
Docker and GitHub Actions; implement a single reproducible environment; run local
notebook and HTTP interaction checks; prepare deployment without publishing.

1. Audit released source and existing workflows/runs; preserve existing user edits.
2. Keep slider-server-environment as the central Project/Manifest location. Use
   .julia-version as the sole Julia version input for local tooling, CI and Docker.
3. Add explicit Pkg.activate in each notebook's imports cell, remove embedded
   environments, and include every active notebook dependency in the shared project.
   Instantiate once during setup/build. Workers still import packages independently.
4. Resolve and generate the real Manifest with portable workspace Julia 1.12.7.
5. Add notebook execution validation that fails on cell errors or private package
   environments; exercise real slider requests and retain stateless game tests.
6. Align CI and image build on the lockfile, gate publishing on validation, add a
   local launcher and container deployment configuration/runbook.
7. Run local Julia checks and all notebooks, attempt Docker validation, lint workflow,
   and verify CRLF on touched text. Record exact results and remaining limitations in
   repository knowledge/INDEX and deployment notes.

Architecture decision: use the official explicit activation pattern in each notebook.
Keeping embedded environments would retain separate resolution; injecting worker
LOAD_PATH alone would not disable Pluto's notebook package manager.

Plan filename review: this is the continued deployment thread, so the existing
file was extended. Its original filename is now narrower than its contents;
suggest `shared-environment-local-tests-deployment.md` when reorganizing plans.
No second plan was created.

Implemented: central version file, union shared project and real manifest; explicit
activation in all active notebooks; analyzer eval dependency fix; local setup,
HTTP/cell validation and export tooling; Compose, tested-image Dockerfile and CI
gating. Evidence and operational guidance promoted to knowledge/deployment.md and
README.md. Linux container execution is still blocked by the unavailable daemon;
no publication/deployment was triggered. Final local test evidence is recorded in
knowledge/deployment.md.


Final result: all four notebooks execute successfully; integration tests 25/25,
scoring tests 41/41, Chromium widget and real-server tests pass (16 state requests,
no page errors). CI export succeeds with matching source bytes. Setup preserves
the lockfile and precompiles. actionlint, Compose config, official image architecture
and CRLF checks pass. Local server is running on loopback port 1234. Actual Docker
build/publication/remote recreation remain unexecuted because no daemon is running.


## Finance notebook background adjustment (2026-10-22)

Remove the finance_plan.jl CSS cell that forces white backgrounds on body, main,
pluto-notebook and the table of contents. Remove its cell-order entry so Pluto's
normal theme controls the background. Preserve calculation and plotting cells.
Verify the targeted override is gone, cell IDs/order match and text remains CRLF.
This continues notebook preparation in the current thread. The broader suggested
plan filename remains shared-environment-local-tests-deployment.md.

Outcome: removed the override cell and its order entry; remaining 79 cells and
cell-order entries match. CRLF checks pass. The running server needs a restart
to reload the changed notebook because directory watching is disabled.


## Restrict analyzer input to mathematical formulas (2026-10-22)

Replace every user-input eval path in function_analyzer.jl with an allowlisted
AST interpreter. Permit finite numeric literals, x/b, pi/e constants, arithmetic,
small literal integer powers and approved elementary functions. Reject every
other AST form before calculation; bound source length, AST size/depth and numeric
literals. Do not execute parsed expressions or resolve names dynamically.
Keep formula display, symbolic derivatives and numeric plotting functional. Invalid
input should show a clear message and recover on the next valid submission.
Put the reusable interpreter in slider-server-environment so Docker includes it.
Add adversarial and mathematical unit tests and run them in Actions and Docker.
Extend real slider HTTP checks with allowed formulas, rejected code and recovery;
run all active notebooks after the change. Preserve CRLF and promote the current
security contract/test outcomes into repository knowledge and INDEX.
The existing plan filename remains narrow; the previously suggested name is
shared-environment-local-tests-deployment.md. Continue this plan rather than
creating a second plan for the same deployment-preparation thread.


Outcome: removed every eval/Meta.parse(text_equation) path from the analyzer.
The bounded MathFormulas interpreter handles numeric plotting and symbolic math;
invalid syntax and real-domain failures show recoverable messages. Unit/security/
symbolic tests pass 153 assertions; full notebook and real HTTP tests pass 56.
CI export passes for all four notebooks, including the 79-cell finance notebook.
Chromium confirms actual formula entry, Confirm, rejected commands/assignment,
out-of-domain feedback and graph recovery. The local server was restarted on
127.0.0.1:1234 and all four notebooks pass startup validation. Workflow actionlint,
export-source parity, notebook cell order and CRLF checks pass. Docker execution
remains unverified because its daemon is unavailable. No publication was performed.
Rules and results promoted to knowledge/function-analyzer.md and INDEX.md.


## Validate user-built Docker image (2026-10-22)

The user completed the Docker build. Verify the image contains the current source,
switch from the verified native Julia process to Compose, check startup/health,
and repeat Chromium interaction checks against Linux. Record the result in
knowledge/deployment.md and update README's remaining deployment steps. No remote
publication or self-hosted container changes are part of this local verification.
Continue this plan; the existing suggested broader filename still fits its scope.

Outcome: local Linux image starts successfully; container is running and healthy.
All four notebooks pass startup validation. Source/version/manifest/security test
files match the workspace hashes. Chromium game and restricted-formula tests pass
against Docker. The native server was replaced by Compose on localhost:1234.
Remote Actions publication and self-hosted deployment remain user-operated.
