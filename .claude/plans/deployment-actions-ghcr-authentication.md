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
