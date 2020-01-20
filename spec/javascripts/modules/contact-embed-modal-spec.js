/* eslint-env jasmine */
/* global ContactEmbedModal, fetchMock, buildModalDialogue, removeModalDialogue */

describe('ContactEmbedModal', function () {
  'use strict'

  var modal, openLink, contactEmbedModal

  beforeEach(function () {
    modal = buildModalDialogue()

    openLink = document.createElement('a')
    openLink.dataset.modalAction = 'open'
    openLink.href = 'https://example.com/contact-embed'

    contactEmbedModal = new ContactEmbedModal(openLink)
    contactEmbedModal.init()
  })

  afterEach(function () {
    removeModalDialogue()
  })

  describe('opening the modal', function () {
    it('opens from a click and renders the linked resource in the modal dynamic section', function (done) {
      fetchMock.get('https://example.com/contact-embed', '<h1>Contact response</h1>')

      openLink.click()

      fetchMock.flush(true).then(function () {
        var dynamicSection = modal.querySelector('.js-dynamic-section')
        expect(dynamicSection).toBeVisible()
        expect(dynamicSection).toContainHtml('<h1>Contact response</h1>')
        done()
      })
    })
  })

  describe('inserting a contact', function () {
    beforeEach(function () {
      modal.open()
      var body = '<form action="https://example.com/contact-embed" method="post" data-modal-action="insert">' +
                   '<button type="submit">Submit</button>' +
                 '</form>'
      contactEmbedModal.workflow.renderSuccess({ body: body })
    })

    it('closes the modal and adds the response to the editor on success', function (done) {
      fetchMock.post('https://example.com/contact-embed', '[Contact:123]')
      modal.querySelector('button').click()
      spyOn(contactEmbedModal.editor, 'insertBlock')
      fetchMock.flush(true).then(function () {
        expect(modal).toBeHidden()
        expect(contactEmbedModal.editor.insertBlock).toHaveBeenCalledWith('[Contact:123]')
        done()
      })
    })

    it('shows the response when there is a validation issue', function (done) {
      fetchMock.post(
        'https://example.com/contact-embed',
        { status: 422, body: '<h1>Validation issues</h1>' }
      )
      modal.querySelector('button').click()
      fetchMock.flush(true).then(function () {
        var dynamicSection = modal.querySelector('.js-dynamic-section')
        expect(dynamicSection).toBeVisible()
        expect(dynamicSection).toContainHtml('<h1>Validation issues</h1>')
        done()
      })
    })

    it('shows the modal error view on a different error response', function (done) {
      fetchMock.post('https://example.com/contact-embed', 500)
      modal.querySelector('button').click()
      fetchMock.flush(true).then(function () {
        var errorSection = modal.querySelector('#error')
        expect(errorSection).toBeVisible()
        done()
      })
    })
  })
})
