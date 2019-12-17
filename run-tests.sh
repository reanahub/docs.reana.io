#!/bin/sh

npx markdownlint-cli docs/* && \
awesome_bot --allow-dupe --skip-save-results --allow-redirect docs/**/*.md && \
mkdocs build -v
rm -rf site/
