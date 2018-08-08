#!/bin/bash

npm install
bundle install
bundle exec unicorn -p 3221
