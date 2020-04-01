/* eslint-env jasmine */
/* global InlineAttachmentModal, fetchMock, buildModalDialogue, removeModalDialogue */

describe('InlineAttachmentModal', function () {
  'use strict'

  var modal, openLink, inlineAttachmentModal

  function itBehavesLikeAFormAction (action) {
    var url = 'https://example.com/' + action
    var body = '<form action="' + url + '" method="post" data-modal-action="' + action + '">' +
                 '<button>Submit</button>' +
               '</form>'

    it('updates the modal with the form response', function (done) {
      modal.open()
      inlineAttachmentModal.workflow.renderSuccess({ body: body })

      fetchMock.post(url, '<h1>Form submitted</h1>')
      var dynamicSection = modal.querySelector('.js-dynamic-section')
      dynamicSection.querySelector('button').click()

      fetchMock.flush(true).then(function () {
        expect(dynamicSection).toBeVisible()
        expect(dynamicSection).toContainHtml('<h1>Form submitted</h1>')
        done()
      })
    })
  }

  function itBehavesLikeALinkAction (action) {
    var url = 'https://example.com/' + action
    var body = '<a href="' + url + '" data-modal-action="' + action + '">Link</a>'

    it('updates the modal with the link response', function (done) {
      modal.open()
      inlineAttachmentModal.workflow.renderSuccess({ body: body })

      fetchMock.get(url, '<h1>Link followed</h1>')
      var dynamicSection = modal.querySelector('.js-dynamic-section')
      dynamicSection.querySelector('a').click()

      fetchMock.flush(true).then(function () {
        expect(dynamicSection).toBeVisible()
        expect(dynamicSection).toContainHtml('<h1>Link followed</h1>')
        done()
      })
    })
  }

  beforeEach(function () {
    modal = buildModalDialogue()

    openLink = document.createElement('a')
    openLink.dataset.modalAction = 'open'
    openLink.href = 'https://example.com/inline-attachment'

    inlineAttachmentModal = new InlineAttachmentModal(openLink)
    inlineAttachmentModal.init()
  })

  afterEach(function () {
    removeModalDialogue()
  })

  describe('open action', function () {
    it('opens when the link is clicked and shows the content', function (done) {
      fetchMock.get('https://example.com/inline-attachment', '<h1>Inline attachment</h1>')
      openLink.click()

      fetchMock.flush(true).then(function () {
        var dynamicSection = modal.querySelector('.js-dynamic-section')
        expect(dynamicSection).toBeVisible()
        expect(dynamicSection).toContainHtml('<h1>Inline attachment</h1>')
        done()
      })
    })
  })

  describe('upload action', function () {
    itBehavesLikeAFormAction('upload')
  })

  describe('insert action', function () {
    itBehavesLikeALinkAction('insert')
  })

  describe('delete action', function () {
    itBehavesLikeALinkAction('delete')
  })

  describe('confirmDelete action', function () {
    itBehavesLikeAFormAction('confirmDelete')
  })

  describe('edit action', function () {
    itBehavesLikeALinkAction('edit')
  })

  describe('update action', function () {
    itBehavesLikeAFormAction('update')
  })

  describe('back action', function () {
    itBehavesLikeALinkAction('back')
  })

  describe('insert-attachment-block action', function () {
    beforeEach(function () {
      modal.open()
      var body = '<form action="https://example.com/insert-block" method="post" ' +
                   'data-modal-action="insert-attachment-block" data-modal-data="[Attachment:file.pdf]">' +
                   '<button>Submit</button>' +
                 '</form>'
      inlineAttachmentModal.workflow.renderSuccess({ body: body })
    })

    it('closes the modal and inserts the form modal data into the editor as block content', function (done) {
      fetchMock.post('https://example.com/insert-block', 200)
      spyOn(inlineAttachmentModal.editor, 'insertBlock')
      modal.querySelector('button').click()
      fetchMock.flush(true).then(function () {
        expect(modal).toBeHidden()
        expect(inlineAttachmentModal.editor.insertBlock).toHaveBeenCalledWith('[Attachment:file.pdf]')
        done()
      })
    })
  })

  describe('insert-attachment-link action', function () {
    beforeEach(function () {
      modal.open()
      var body = '<form action="https://example.com/insert-link" method="post" ' +
                   'data-modal-action="insert-attachment-link" data-modal-data="[AttachmentLink:file.pdf]">' +
                   '<button>Submit</button>' +
                 '</form>'
      inlineAttachmentModal.workflow.renderSuccess({ body: body })
    })

    it('closes the modal and inserts the form modal data into the editor as inline content', function (done) {
      fetchMock.post('https://example.com/insert-link', 200)
      spyOn(inlineAttachmentModal.editor, 'insertInline')
      modal.querySelector('button').click()
      fetchMock.flush(true).then(function () {
        expect(modal).toBeHidden()
        expect(inlineAttachmentModal.editor.insertInline).toHaveBeenCalledWith('[AttachmentLink:file.pdf]')
        done()
      })
    })
  })
})
