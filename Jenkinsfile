#!/usr/bin/env groovy

library("govuk")

node {
  // This is required for assets:precompile which runs in rails production
  govuk.setEnvar("JWT_AUTH_SECRET", "secret")

  govuk.buildProject(
    beforeTest: {
      stage("Lint Javascript") {
        sh("yarn install --ignore-engines")
        sh("yarn run lint")
      }
    },
    rubyLintDiff: false,
    rubyLintDirs: "",
    overrideTestTask: {
      stage("Run tests") {
        govuk.runTests("spec jasmine:ci")
      }
    },
    afterTest: {
      stage("Lint FactoryBot") {
        sh("bundle exec rake factorybot:lint RAILS_ENV=test")
      }
    }
  )
}
