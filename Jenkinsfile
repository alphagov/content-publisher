#!/usr/bin/env groovy

library("govuk@default-branch")

node {
  // This is required for assets:precompile which runs in rails production
  govuk.setEnvar("JWT_AUTH_SECRET", "secret")

  govuk.buildProject()
}
