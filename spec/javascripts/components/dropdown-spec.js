/* global describe beforeEach afterEach it expect */
/* global GOVUK, $ */

describe('Toolbar dropdown component', function () {
  'use strict'

  var container

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML =
    '<details class="app-c-toolbar-dropdown" data-module="toolbar-dropdown" role="group">' +
      '<summary class="app-c-toolbar-dropdown__title" role="button">Insert...</summary>' +
      '<div class="app-c-toolbar-dropdown__container">' +
        '<ul class="app-c-toolbar-dropdown__list">' +
          '<li class="app-c-toolbar-dropdown__list-item">' +
            '<button class="app-c-toolbar-dropdown__button">Image</button>' +
          '</li>' +
          '<li class="app-c-toolbar-dropdown__list-item">' +
            '<button class="app-c-toolbar-dropdown__button">Contact</button>' +
          '</li>' +
        '</ul>' +
      '</div>' +
    '</details>'

    document.body.classList.add('js-enabled')
    document.body.appendChild(container)
    var element = document.querySelector('[data-module="toolbar-dropdown"]')
    new GOVUK.Modules.ToolbarDropdown().start($(element))
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  it('should hide the overlay container', function () {
    var overlay = document.querySelector('.app-c-toolbar-dropdown__container')
    expect(overlay).toBeHidden()
  })

  it('should show the overlay container on title click', function () {
    document.querySelector('.app-c-toolbar-dropdown__title').click()
    var overlay = document.querySelector('.app-c-toolbar-dropdown__container')
    expect(overlay).toBeVisible()
  })

  it('should hide the overlay container on button click', function () {
    document.querySelector('.app-c-toolbar-dropdown__title').click()
    document.querySelector('.app-c-toolbar-dropdown__button').click()
    var overlay = document.querySelector('.app-c-toolbar-dropdown__container')
    expect(overlay).toBeHidden()
  })
})
