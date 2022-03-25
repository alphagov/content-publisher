/* global VideoEmbedModal, fetchMock, buildModalDialogue, removeModalDialogue */

describe('VideoEmbedModal', function () {
  'use strict'

  var modal, openLink, videoEmbedModal

  beforeEach(function () {
    modal = buildModalDialogue()

    openLink = document.createElement('a')
    openLink.dataset.modalAction = 'open'
    openLink.href = 'https://example.com/video-embed'

    videoEmbedModal = new VideoEmbedModal(openLink)
    videoEmbedModal.init()
  })

  afterEach(function () {
    removeModalDialogue()
  })

  describe('open action', function () {
    it('opens from a click and renders the linked resource in the modal dynamic section', function (done) {
      fetchMock.get('https://example.com/video-embed', '<h1>Video response</h1>')
      openLink.click()

      fetchMock.flush(true).then(function () {
        var dynamicSection = modal.querySelector('.js-dynamic-section')
        expect(dynamicSection).toBeVisible()
        expect(dynamicSection.innerHTML).toContain('<h1>Video response</h1>')
        done()
      })
    })
  })

  describe('insert action', function () {
    beforeEach(function () {
      modal.open()
      var body = '<form action="https://example.com/video-embed" method="post" data-modal-action="insert">' +
                   '<button>Submit</button>' +
                 '</form>'
      videoEmbedModal.workflow.renderSuccess({ body: body })
    })

    it('closes the modal and adds the response to the editor on success', function (done) {
      fetchMock.post('https://example.com/video-embed', '[link](https://www.youtube.com/id)')
      modal.querySelector('button').click()
      spyOn(videoEmbedModal.editor, 'insertBlock')
      fetchMock.flush(true).then(function () {
        expect(modal).toBeHidden()
        expect(videoEmbedModal.editor.insertBlock).toHaveBeenCalledWith('[link](https://www.youtube.com/id)')
        done()
      })
    })

    it('shows the response when there is a validation issue', function (done) {
      fetchMock.post(
        'https://example.com/video-embed',
        { status: 422, body: '<h1>Validation issues</h1>' }
      )
      modal.querySelector('button').click()
      fetchMock.flush(true).then(function () {
        var dynamicSection = modal.querySelector('.js-dynamic-section')
        expect(dynamicSection).toBeVisible()
        expect(dynamicSection.innerHTML).toContain('<h1>Validation issues</h1>')
        done()
      })
    })

    it('shows the modal error view on a different error response', function (done) {
      fetchMock.post('https://example.com/video-embed', 500)
      modal.querySelector('button').click()
      fetchMock.flush(true).then(function () {
        var errorSection = modal.querySelector('#error')
        expect(errorSection).toBeVisible()
        done()
      })
    })
  })
})
