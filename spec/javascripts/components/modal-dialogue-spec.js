/* global describe beforeEach afterEach it expect */
/* global ModalDialogue */

function keyPress (element, key) {
  var event = document.createEvent('Event')
  event.keyCode = key // Deprecated, prefer .key instead
  event.key = key
  event.initEvent('keydown')
  element.dispatchEvent(event)
}

describe('Modal dialogue component', function () {
  'use strict'

  var container

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML =
    '<button class="govuk-button" data-toggle="modal" data-target="my-modal">Launch modal dialogue</button>' +
    '<div class="app-c-modal-dialogue" data-module="modal-dialogue" id="my-modal">' +
      '<dialog class="app-c-modal-dialogue__box" aria-modal="true" role="dialogue" aria-labelledby="my-modal-title">' +
        '<div class="app-c-modal-dialogue__container">' +
          '<div class="app-c-modal-dialogue__content">' +
            '<h2 id="my-modal-title">Modal title</h2>' +
          '</div>' +
          '<button class="app-c-modal-dialogue__close-button" aria-label="Close modal dialogue">&times;</button>' +
        '</div>' +
      '</dialog>' +
      '<div class="app-c-modal-dialogue__overlay"></div>' +
    '</div>' +

    document.body.classList.add('js-enabled')
    document.body.appendChild(container)
    var element = document.querySelector('[data-module="modal-dialogue"]')
    new GOVUK.Modules.ModalDialogue().start($(element))
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  it('should hide the modal dialogue', function () {
    var modal = document.querySelector('.app-c-modal-dialogue')
    expect(modal).toBeHidden()
  })

  describe('open button', function () {
    beforeEach(function () {
      document.querySelector('.govuk-button').click()
    })

    afterEach(function () {
      document.querySelector('.app-c-modal-dialogue__close-button').click()
    })

    it('should show the modal dialogue', function () {
      var modal = document.querySelector('.app-c-modal-dialogue')
      expect(modal).toBeVisible()
    })
  })

  describe('esc key', function () {
    it('should close the modal', function () {
      var modal = document.querySelector('.app-c-modal-dialogue')
      modal.open()

      keyPress(modal, 27)
      expect(modal).toBeHidden()
    })
  })

  describe('close button', function () {
    it('should hide the modal dialogue', function () {
      document.querySelector('.govuk-button').dispatchEvent(new Event('focus'))
      document.querySelector('.govuk-button').click()
      document.querySelector('.app-c-modal-dialogue__close-button').click()

      var modal = document.querySelector('.app-c-modal-dialogue')
      document.querySelector('.app-c-modal-dialogue__close-button').click()
      expect(modal).toBeHidden()
    })
  })

  describe('open', function () {
    beforeEach(function () {
      var modal = document.querySelector('.app-c-modal-dialogue')
      modal.open()
    })

    afterEach(function () {
      var modal = document.querySelector('.app-c-modal-dialogue')
      modal.close()
    })

    it('should show the modal dialogue', function () {
      var modal = document.querySelector('.app-c-modal-dialogue')
      expect(modal).toBeVisible()
    })

    it('should focus the modal dialogue', function () {
      var modalFocused = document.querySelector('.app-c-modal-dialogue__box')
      expect(modalFocused).toBeTruthy()
    })
  })

  describe('close', function () {
    it('should hide the modal dialogue', function () {
      var modal = document.querySelector('.app-c-modal-dialogue')
      modal.open()
      modal.close()
      expect(modal).toBeHidden()
    })
  })
})
