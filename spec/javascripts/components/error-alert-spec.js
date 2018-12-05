/* global describe beforeEach afterEach it expect */
/* global ErrorAlert */

describe('Error alert component', function () {
  'use strict'

  var container
  var module

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML =
      '<div class="app-c-error-alert" data-module="error-alert" role="alert" tabindex="-1">' +
        '<p class="app-c-error-alert__message">Message to alert the user to an unsuccessful action goes here</p>' +
      '</div>'

    document.body.appendChild(container)
    var element = document.querySelector('[data-module="error-alert"]')
    module = new ErrorAlert(element)
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  it('should be focused', function () {
    var element = document.querySelector('[data-module="error-alert"]')
    module.focus()
    expect(element).toBeFocused()
  })
})
