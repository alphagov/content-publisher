#!/usr/bin/env groovy

library("govuk")

node {
  govuk.buildProject(
    brakeman: true,
    sassLint: true,
    rubyLintDiff: false
  )
}
