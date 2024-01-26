#!/usr/bin/env bash
#
# This file is part of REANA.
# Copyright (C) 2020, 2024 CERN.
#
# REANA is free software; you can redistribute it and/or modify it
# under the terms of the MIT License; see LICENSE file for more details.

set -o errexit
set -o nounset

check_commitlint () {
    from=${2:-master}
    to=${3:-HEAD}
    npx commitlint --from="$from" --to="$to"
    found=0
    while IFS= read -r line; do
        if echo "$line" | grep -qP "\(\#[0-9]+\)$"; then
            true
        else
            echo "✖   PR number missing in $line"
            found=1
        fi
    done < <(git log "$from..$to" --format="%s")
    if [ $found -gt 0 ]; then
        exit 1
    fi
}

check_shellcheck () {
    find . -name "*.sh" -exec shellcheck {} \+
}

check_docstyle () {
    npx -p markdownlint-cli markdownlint docs/*
    awesome_bot --allow-dupe --skip-save-results --allow-redirect docs/**/*.md
}

build_docs () {
    mkdocs build -v
    rm -rf site/
}

if [ $# -eq 0 ]; then
    check_commitlint
    check_shellcheck
    check_docstyle
    build_docs
fi

arg="$1"
case $arg in
    --check-commitlint) check_commitlint "$@";;
    --check-shellcheck) check_shellcheck;;
    --check-docstyle) check_docstyle;;
    --build-docs) build_docs;;
    *) echo "[ERROR] Invalid argument '$arg'. Exiting." && exit 1;;
esac
