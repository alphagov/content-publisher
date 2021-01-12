/* global InlineImageModal, fetchMock, buildModalDialogue, removeModalDialogue */

describe('InlineImageModal', function () {
  'use strict'

  var modal, openLink, inlineImageModal

  function itBehavesLikeAFormAction (action) {
    var url = 'https://example.com/' + action
    var body = '<form action="' + url + '" method="post" data-modal-action="' + action + '">' +
                 '<button>Submit</button>' +
               '</form>'

    it('updates the modal with the form response', function (done) {
      modal.open()
      inlineImageModal.workflow.renderSuccess({ body: body })

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
      inlineImageModal.workflow.renderSuccess({ body: body })

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
    openLink.href = 'https://example.com/inline-image'

    inlineImageModal = new InlineImageModal(openLink)
    inlineImageModal.init()
  })

  afterEach(function () {
    removeModalDialogue()
  })

  describe('open action', function () {
    it('opens when the link is clicked and shows the content', function (done) {
      fetchMock.get('https://example.com/inline-image', '<h1>Inline image</h1>')
      openLink.click()

      fetchMock.flush(true).then(function () {
        var dynamicSection = modal.querySelector('.js-dynamic-section')
        expect(dynamicSection).toBeVisible()
        expect(dynamicSection).toContainHtml('<h1>Inline image</h1>')
        done()
      })
    })
  })

  describe('insert action', function () {
    it('inserts the markdown into the editor and closes the modal', function () {
      var markdown = '[Image:file.jog]'
      var body = '<button type="button" data-modal-action="insert" data-modal-data="' + markdown + '">Insert</button>'
      modal.open()
      inlineImageModal.workflow.renderSuccess({ body: body })
      spyOn(inlineImageModal.editor, 'insertBlock')

      modal.querySelector('button').click()
      expect(modal).toBeHidden()
      expect(inlineImageModal.editor.insertBlock).toHaveBeenCalledWith(markdown)
    })
  })

  describe('upload action', function () {
    itBehavesLikeAFormAction('upload')
  })

  describe('back action', function () {
    itBehavesLikeALinkAction('back')
  })

  describe('crop action', function () {
    itBehavesLikeAFormAction('crop')
  })

  describe('delete action', function () {
    itBehavesLikeALinkAction('delete')
  })

  describe('confirmDelete action', function () {
    itBehavesLikeAFormAction('confirmDelete')
  })

  describe('meta action', function () {
    itBehavesLikeAFormAction('meta')
  })

  describe('edit action', function () {
    itBehavesLikeALinkAction('edit')
  })

  describe('metaInsert action', function () {
    beforeEach(function () {
      modal.open()
      var body = '<form action="https://example.com/meta-insert" method="post" ' +
                   'data-modal-action="metaInsert" data-modal-data="[Image:file.jpg]">' +
                   '<button>Submit</button>' +
                 '</form>'
      inlineImageModal.workflow.renderSuccess({ body: body })
    })

    it('closes the modal and inserts the form modal data into the editor', function (done) {
      fetchMock.post('https://example.com/meta-insert', 200)
      modal.querySelector('button').click()
      spyOn(inlineImageModal.editor, 'insertBlock')
      fetchMock.flush(true).then(function () {
        expect(modal).toBeHidden()
        expect(inlineImageModal.editor.insertBlock).toHaveBeenCalledWith('[Image:file.jpg]')
        done()
      })
    })

    it('shows the response when there is a validation issue', function (done) {
      fetchMock.post(
        'https://example.com/meta-insert',
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
      fetchMock.post('https://example.com/meta-insert', 500)
      modal.querySelector('button').click()
      fetchMock.flush(true).then(function () {
        var errorSection = modal.querySelector('#error')
        expect(errorSection).toBeVisible()
        done()
      })
    })
  })
})
