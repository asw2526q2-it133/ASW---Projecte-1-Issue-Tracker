#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Ejecuta las migraciones en el servidor de base de datos separado
bundle exec rails db:migrate

bundle exec rails db:seed