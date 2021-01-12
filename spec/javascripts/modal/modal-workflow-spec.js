/* global ModalWorkflow, buildModalDialogue, removeModalDialogue */

describe('ModalWorkflow', function () {
  'use strict'

  var actionCallback, modal, modalWorkflow

  beforeEach(function () {
    actionCallback = jasmine.createSpy('actionCallback')
    modal = buildModalDialogue()
    modal.open()
    modalWorkflow = new ModalWorkflow(modal, actionCallback)
  })

  afterEach(function () {
    removeModalDialogue()
  })

  describe('modalWorkflow.performAction', function () {
    it('shows a focused loading modal', function () {
      spyOn(modal, 'focusDialog')
      var loadingSection = modal.querySelector('#loading')

      modalWorkflow.performAction(document.createElement('a'))

      expect(modal.focusDialog).toHaveBeenCalled()
      expect(loadingSection).toBeVisible()
    })

    it('calls the provided actionCallback', function () {
      var item = document.createElement('a')
      modalWorkflow.performAction(item)
      expect(actionCallback).toHaveBeenCalledWith(item)
    })
  })

  describe('modalWorkflow.renderSuccess', function () {
    var dynamicSection, modalDialogue

    beforeEach(function () {
      dynamicSection = modal.querySelector('.js-dynamic-section')
      modalDialogue = modal.querySelector('dialog')
      spyOn(modalWorkflow, 'performAction')
    })

    it('renders the result in the modals dynamic section', function () {
      modalWorkflow.renderSuccess({ body: '<h1>Success</h1>' })
      expect(dynamicSection).toBeVisible()
      expect(dynamicSection).toContainHtml('<h1>Success</h1>')
    })

    it('sets the dynamic section heading as label for the modal', function () {
      modalWorkflow.renderSuccess({ body: '<h1>Success</h1>' })
      expect(modalDialogue.getAttribute('aria-label')).toEqual('Success')
    })

    it('intercepts submits on forms with modal-action data attributes', function () {
      var body = '<form action="/" data-modal-action="anything">' +
                   '<button>Submit</button>' +
                 '</form>'
      modalWorkflow.renderSuccess({ body: body })
      var form = dynamicSection.querySelector('form')
      form.querySelector('button').click()
      expect(modalWorkflow.performAction).toHaveBeenCalledWith(form)
    })

    it('intercepts clicks on links with modal-action data attributes', function () {
      var body = '<a href="/" data-modal-action="anything">link</a>'
      modalWorkflow.renderSuccess({ body: body })
      var link = dynamicSection.querySelector('a')
      link.click()
      expect(modalWorkflow.performAction).toHaveBeenCalledWith(link)
    })

    it('intercepts clicks on buttons with modal-action data attributes', function () {
      var body = '<form action="/" data-modal-action="anything">' +
                   '<button data-modal-action="anything">Submit</button>' +
                 '</form>'
      modalWorkflow.renderSuccess({ body: body })
      var form = dynamicSection.querySelector('form')
      var button = dynamicSection.querySelector('button')
      button.click()
      expect(modalWorkflow.performAction).toHaveBeenCalledWith(button)
      expect(modalWorkflow.performAction).not.toHaveBeenCalledWith(form)
    })

    it('initialisises the components within the modal', function () {
      spyOn(window.GOVUK.modules, 'start')
      spyOn(window.GOVUKFrontend, 'initAll')
      modalWorkflow.renderSuccess({ body: '' })
      expect(window.GOVUK.modules.start).toHaveBeenCalledWith($(modal))
      expect(window.GOVUKFrontend.initAll).toHaveBeenCalledWith(modal)
    })
  })

  describe('modalWorkflow.renderError', function () {
    var errorSection, modalDialogue, error

    beforeEach(function () {
      errorSection = modal.querySelector('#error')
      modalDialogue = modal.querySelector('dialog')
      error = new Error('Failed')
      spyOn(window.Raven, 'captureException')
      spyOn(console, 'error')
    })

    it('shows the error section', function () {
      modalWorkflow.renderError(error)
      expect(errorSection).toBeVisible()
    })

    it('sets the dynamic section heading as label for the modal', function () {
      modalWorkflow.renderError(error)
      expect(modalDialogue.getAttribute('aria-label')).toEqual('Something has gone wrong')
    })

    it('logs the error to the console and to raven', function () {
      modalWorkflow.renderError(error)
      expect(window.Raven.captureException).toHaveBeenCalledWith(error)
      expect(console.error).toHaveBeenCalledWith(error)
    })
  })

  describe('.render', function () {
    beforeEach(function () {
      spyOn(modalWorkflow, 'renderSuccess')
      spyOn(modalWorkflow, 'renderError')
    })

    it('delegates to render success on a resolved promise response', function (done) {
      var response = window.Promise.resolve('success')
      modalWorkflow.render(response)

      // timeout to ensure running after promise handling has completed
      setTimeout(function () {
        expect(modalWorkflow.renderSuccess).toHaveBeenCalledWith('success')
        done()
      }, 0)
    })

    it('delegates to render error on a rejected promise response', function (done) {
      var response = window.Promise.reject('error')
      modalWorkflow.render(response)

      // timeout to ensure running after promise handling has completed
      setTimeout(function () {
        expect(modalWorkflow.renderError).toHaveBeenCalledWith('error')
        done()
      }, 0)
    })
  })
})
