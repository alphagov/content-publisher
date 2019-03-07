/* eslint-env jasmine, jquery */
/* global GOVUK */

describe('Multi section viewer', function () {
  'use strict'

  var container, element

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML =
      '<button class="govuk-button" data-toggle="multi-section-viewer" data-target="sections" data-target-section="section-1">Show Section 1</button>' +
      '<button class="govuk-button" data-toggle="multi-section-viewer" data-target="sections" data-target-section="section-2">Show Section 2</button>' +
      '<div id="sections" data-module="multi-section-viewer">' +
        '<div class="app-c-multi-section-viewer__section" id="section-1">' +
          'Section 1' +
        '</div>' +
        '<div class="app-c-multi-section-viewer__section" id="section-2">' +
          'Section 2' +
        '</div>' +
        '<div class="app-c-multi-section-viewer__section js-dynamic-section">' +
        '</div>' +
      '</div>'

    document.body.appendChild(container)
    element = document.querySelector('[data-module="multi-section-viewer"]')
    new GOVUK.Modules.MultiSectionViewer().start($(element))
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  it('hides all the sections', function () {
    var section1 = document.querySelector('#section-1')
    var section2 = document.querySelector('#section-2')
    var dynamicSection = document.querySelector('.js-dynamic-section')

    expect(section1).toBeHidden()
    expect(section2).toBeHidden()
    expect(dynamicSection).toBeHidden()
  })

  describe('section buttons', function () {
    it('shows only a single section at a time', function () {
      var section1 = document.querySelector('#section-1')
      var section2 = document.querySelector('#section-2')
      var dynamicSection = document.querySelector('.js-dynamic-section')

      var section1Button = document.querySelector('[data-target-section="section-1"]')
      section1Button.click()

      expect(section1).toBeVisible()
      expect(section2).toBeHidden()
      expect(dynamicSection).toBeHidden()

      var section2Button = document.querySelector('[data-target-section="section-2"]')
      section2Button.click()

      expect(section2).toBeVisible()
      expect(section1).toBeHidden()
      expect(dynamicSection).toBeHidden()
    })
  })

  describe('showStaticSection', function () {
    it('shows only a single section at a time', function () {
      var section1 = document.querySelector('#section-1')
      var section2 = document.querySelector('#section-2')
      var dynamicSection = document.querySelector('.js-dynamic-section')

      dynamicSection.style.display = 'block'

      element.showStaticSection('section-1')
      expect(section1).toBeVisible()
      expect(section2).toBeHidden()
      expect(dynamicSection).toBeHidden()

      element.showStaticSection('section-2')
      expect(section2).toBeVisible()
      expect(section1).toBeHidden()
      expect(dynamicSection).toBeHidden()
    })
  })

  describe('showDynamicSection', function () {
    it('shows only the dynamic section', function () {
      var dynamicSection = document.querySelector('.js-dynamic-section')
      var section1 = document.querySelector('#section-1')

      section1.style.display = 'block'
      element.showDynamicSection('<div>Dynamic</div>')
      expect(dynamicSection).toBeVisible()
      expect(section1).toBeHidden()
    })

    it('sets the content of the dynamic section', function () {
      var dynamicSection = document.querySelector('.js-dynamic-section')
      element.showDynamicSection('<div>Dynamic</div>')
      expect(dynamicSection.innerHTML).toEqual('<div>Dynamic</div>')
    })
  })

  describe('hideAllSections', function () {
    it('hides all sections', function () {
      var section1 = document.querySelector('#section-1')
      var dynamicSection = document.querySelector('.js-dynamic-section')

      section1.style.display = 'block'
      dynamicSection.style.display = 'block'

      element.hideAllSections()
      expect(section1).toBeHidden()
      expect(dynamicSection).toBeHidden()
    })
  })
})
