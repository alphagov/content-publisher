#!/bin/bash

bundle install
gem install foreman --conservative
foreman start -f Procfile.dev
