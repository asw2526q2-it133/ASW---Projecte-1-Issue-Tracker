#!/bin/bash
set -eu

echo "=== Building Rails Application ==="

# Install dependencies
bundle install

# Precompile assets
bin/rails assets:precompile
bin/rails assets:clean

# Run database migrations
bin/rails db:migrate

echo "=== Build Complete ==="