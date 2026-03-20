#!/bin/bash
set -eu

echo "=== Building Rails Application ==="

# Install dependencies
bundle install

# Precompile assets
bin/rails assets:precompile

echo "=== Build Complete ==="
