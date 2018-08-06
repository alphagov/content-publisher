#!/usr/bin/env groovy

library("govuk")

node {
  govuk.buildProject(
    beforeTest: {
      stage("Lint Javascript") {
        sh("npm install")
        sh("npm run lint --silent")
      }
    },
    brakeman: true
  )
}
