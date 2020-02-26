/* eslint-env jasmine, jquery */
/* global GOVUK */

describe('Reorderable list component', function () {
  'use strict'

  var container
  var element

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML =
    '<ol class="app-c-reorderable-list" data-module="reorderable-list">' +
      '<li class="app-c-reorderable-list__item">' +
        '<div class="app-c-reorderable-list__wrapper">' +
          '<div class="app-c-reorderable-list__content">' +
            '<p class="app-c-reorderable-list__title">First attachment</p>' +
          '</div>' +
          '<div class="app-c-reorderable-list__actions">' +
            '<input type="hidden" name="original_order[]" value="1">' +
            '<input name="new_order[]" value="1" class="gem-c-input govuk-input govuk-input--width-2" id="input-278a8924" type="text">' +
            '<button type="button">Up</button>' +
            '<button type="button">Down</button>' +
          '</div>' +
        '</div>' +
      '</li>' +
      '<li class="app-c-reorderable-list__item">' +
        '<div class="app-c-reorderable-list__wrapper">' +
          '<div class="app-c-reorderable-list__content">' +
            '<p class="app-c-reorderable-list__title">Second attachment</p>' +
          '</div>' +
          '<div class="app-c-reorderable-list__actions">' +
            '<input type="hidden" name="original_order[]" value="2">' +
            '<input name="new_order[]" value="2" class="gem-c-input govuk-input govuk-input--width-2" id="input-278a8924" type="text">' +
            '<button type="button">Up</button>' +
            '<button type="button">Down</button>' +
          '</div>' +
        '</div>' +
      '</li>' +
    '</ol>'

    document.body.classList.add('js-enabled')
    document.body.appendChild(container)
    element = document.querySelector('[data-module="reorderable-list"]')
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  describe('when `matchMedia` is not supported', function () {
    var matchMedia = window.matchMedia
    var mockMatchMedia
    var reorderableList

    beforeEach(function () {
      window.matchMedia = mockMatchMedia
      reorderableList = new GOVUK.Modules.ReorderableList()
      spyOn(reorderableList, 'setupResponsiveChecks')
      reorderableList.start($(element))
    })

    afterEach(function () {
      window.matchMedia = matchMedia
    })

    it('should not setup responsive checks', function () {
      expect(reorderableList.setupResponsiveChecks).not.toHaveBeenCalled()
    })

    it('should disable drag and drop', function () {
      expect(reorderableList.sortable.option('disabled')).toBe(true)
    })
  })

  describe('when `matchMedia` is supported', function () {
    var matchMedia = window.matchMedia
    var mockMatchMedia = matchMedia
    var reorderableList

    var matchMediaMock = function (reorderableList, matches) {
      var bindedcheckMode = reorderableList.checkMode.bind(reorderableList)
      reorderableList.mediaQueryList = { matches: matches }
      reorderableList.sortable = new window.Sortable.create(element) // eslint-disable-line new-cap
      spyOn(reorderableList.sortable, 'option')
      bindedcheckMode()
    }

    beforeEach(function () {
      window.matchMedia = mockMatchMedia
      reorderableList = new GOVUK.Modules.ReorderableList()
    })

    afterEach(function () {
      window.matchMedia = matchMedia
    })

    it('should setup responsive checks', function () {
      spyOn(reorderableList, 'setupResponsiveChecks')
      reorderableList.start($(element))

      expect(reorderableList.setupResponsiveChecks).toHaveBeenCalled()
    })

    it('should enable drag and drop if rendered on a large device', function () {
      matchMediaMock(reorderableList, true)

      expect(reorderableList.sortable.option).toHaveBeenCalledWith('disabled', false)
    })

    it('should disable drag and drop if rendered on a small device', function () {
      matchMediaMock(reorderableList, false)

      expect(reorderableList.sortable.option).toHaveBeenCalledWith('disabled', true)
    })
  })
})
