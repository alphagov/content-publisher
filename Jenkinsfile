#!/usr/bin/env groovy

library("govuk")

node {
  govuk.buildProject(
    beforeTest: {
      stage("Lint Javascript") {
        sh("yarn")
        sh("yarn run lint")
      }
    },
    rubyLintDiff: false,
    rubyLintRails: true,
    rubyLintDirs: "",
    overrideTestTask: {
      stage("Run tests") {
        govuk.runTests("spec")
      }
    }
  )
}
