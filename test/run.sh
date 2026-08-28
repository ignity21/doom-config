#!/bin/sh
# Run the config-invariant lint (and ERT suites once they exist).
# Thin wrapper around the Makefile so it can be wired into CI or a
# pre-commit hook.
set -e
cd "$(dirname "$0")/.."
make lint
make test
