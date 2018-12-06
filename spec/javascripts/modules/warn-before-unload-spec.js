/* global describe beforeEach afterEach it spyOn expect */
/* global WarnBeforeUnload */

describe('Warn before unload module', function () {
  'use strict'

  var container

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML =
      '<form data-warn-before-unload="true">' +
        '<input type="text">' +
      '</form>'
    document.body.appendChild(container)

    var form = document.querySelector('[data-warn-before-unload="true"]')
    new WarnBeforeUnload(form).init()
  })

  afterEach(function () {
    document.body.removeChild(container)
    window.removeEventListener('beforeunload', WarnBeforeUnload.handleBeforeUnload)
  })

  it('should set a before unload event when the form changes', function () {
    spyOn(window, 'addEventListener');
    var input = container.querySelector('input')
    input.dispatchEvent(new Event('change', { bubbles: true }))
    expect(window.addEventListener)
      .toHaveBeenCalledWith('beforeunload', WarnBeforeUnload.handleBeforeUnload)
  })

  it('should remove the before unload event when the form is submitted', function () {
    spyOn(window, 'removeEventListener');
    var form = container.querySelector('form')
    form.dispatchEvent(new Event('submit'))
    expect(window.removeEventListener)
      .toHaveBeenCalledWith('beforeunload', WarnBeforeUnload.handleBeforeUnload)
  })
})
