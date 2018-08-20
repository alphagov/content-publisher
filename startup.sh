#!/bin/bash

yarn install
bundle install
bundle exec foreman start -f Procfile.dev
