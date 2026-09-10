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
