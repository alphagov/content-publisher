#!/usr/bin/env groovy

library("govuk")

node {
  // This is required for assets:precompile which runs in rails production
  govuk.setEnvar("JWT_AUTH_SECRET", "secret")

  govuk.buildProject(
    beforeTest: {
      stage("Lint Javascript") {
        sh("yarn")
        sh("yarn run lint")
      }
    },
    brakeman: true,
    rubyLintDiff: false,
    rubyLintDirs: "",
    overrideTestTask: {
      stage("Run tests") {
        govuk.runTests("spec")
      }
    }
  )
}
