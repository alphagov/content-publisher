/* global describe beforeEach afterEach it expect */
/* global ErrorAlert */
var $ = window.jQuery

describe('Error alert component', function () {
  'use strict'

  var module
  var element

  beforeEach(function () {
    element = $(`
      <div class="app-c-error-alert" data-module="error-alert" role="alert" tabindex="-1">
        <p class="app-c-error-alert__message">Message to alert the user to an unsuccessful action goes here</p>
      </div>`
    )
    $(document.body).append(element)
    module = new ErrorAlert(element)
  })

  afterEach(function () {
    element.remove()
    element = undefined
  })

  it('should be focused', function () {
    module.focus()
    expect(element[0]).toBeFocused()
  })
})
