#!/usr/bin/env bash

KTLINT_VERSION="1.7.1"

# Check if ktlint is present, fail if not
if ! command -v ktlint &> /dev/null; then
    echo "Error: ktlint not found. Please download ktlint $KTLINT_VERSION first." >&2
    exit 1
fi

ktlint --format "$@"
