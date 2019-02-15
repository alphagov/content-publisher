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
    '<button class="govuk-button" data-toggle="modal" data-target="#my-modal">Launch modal dialogue</button>' +
    '<div class="app-c-modal-dialogue" data-module="modal-dialogue" id="my-modal">' +
      '<dialog class="app-c-modal-dialogue__box" aria-modal="true" role="dialogue" aria-labelledby="my-modal-title">' +
        '<div class="app-c-modal-dialogue__container">' +
          '<div class="app-c-modal-dialogue__content">' +
            '<h2 id="my-modal-title" class="app-c-modal-dialogue__title">Modal title</h2>' +
          '</div>' +
          '<button class="app-c-modal-dialogue__close-button" aria-label="Close modal dialogue">&times;</button>' +
        '</div>' +
      '</dialog>' +
      '<div class="app-c-modal-dialogue__overlay"></div>' +
    '</div>' +

    document.body.classList.add('js-enabled')
    document.body.appendChild(container)
    var element = document.querySelector('[data-module="modal-dialogue"]')
    new ModalDialogue(element).init()
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  it('should hide the modal dialogue', function () {
    var modal = document.querySelector('.app-c-modal-dialogue')
    expect(modal).toBeHidden()
  })

  describe('when clicking "Launch modal dialogue" button', function () {
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

    it('should focus the modal dialogue', function () {
      var modalFocused = document.querySelector('.app-c-modal-dialogue__box')
      expect(modalFocused).toBeTruthy()
    })

    it('should close the modal if ESC key is pressed', function () {
      var modal = document.querySelector('.app-c-modal-dialogue')
      keyPress(modal, 27)

      expect(modal).toBeHidden()
    })
  })

  describe('when clicking "Close" button', function () {
    it('should hide the modal dialogue', function () {
      document.querySelector('.govuk-button').focus()
      document.querySelector('.govuk-button').click()
      document.querySelector('.app-c-modal-dialogue__close-button').click()

      var modal = document.querySelector('.app-c-modal-dialogue')
      document.querySelector('.app-c-modal-dialogue__close-button').click()
      expect(modal).toBeHidden()
    })

    it('should return focus to last focused element on close', function () {
      document.querySelector('.govuk-button').focus()
      document.querySelector('.govuk-button').click()
      document.querySelector('.app-c-modal-dialogue__close-button').click()

      var buttonFocused = document.querySelector('.govuk-button:focus')
      expect(buttonFocused).toBeTruthy()
    })
  })
})
