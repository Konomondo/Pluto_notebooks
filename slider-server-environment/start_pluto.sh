#!/usr/bin/env bash
set -euo pipefail
exec julia --startup-file=no "$(dirname "$0")/run_server.jl"
