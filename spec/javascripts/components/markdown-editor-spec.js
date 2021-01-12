/* global spyOnEvent, buildMarkdownEditor, removeMarkdownEditor */

describe('Markdown editor component', function () {
  'use strict'

  beforeEach(function () {
    buildMarkdownEditor()
  })

  afterEach(function () {
    removeMarkdownEditor()
  })

  it('should show the editor header', function () {
    var head = document.querySelector('.js-markdown-editor__head')
    expect(head).toBeVisible()
  })

  it('should show the editor toolbar', function () {
    var toolbar = document.querySelector('.app-c-markdown-editor__toolbar')
    expect(toolbar).toBeVisible()
  })

  it('should show the markdown editor container', function () {
    var editorInput = document.querySelector('.js-markdown-editor-input')
    expect(editorInput).toBeVisible()
  })

  it('should hide the preview container', function () {
    var previewBody = document.querySelector('.js-markdown-preview-body')
    expect(previewBody).toBeHidden()
  })

  describe('when clicking "Preview markdown" button', function () {
    beforeEach(function () {
      document.querySelector('.js-markdown-preview-button').click()
    })

    it('should hide the editor toolbar', function () {
      var toolbar = document.querySelector('.app-c-markdown-editor__toolbar')
      expect(toolbar).toBeHidden()
    })

    it('should not mark the edit markdown button as selected', function () {
      var editButton = document.querySelector('.js-markdown-edit-button')
      expect(editButton).not.toHaveClass('app-c-markdown-editor__button--muted')
    })

    it('should mark the preview markdown button as selected', function () {
      var previewButton = document.querySelector('.js-markdown-preview-button')
      expect(previewButton).toHaveClass('app-c-markdown-editor__button--muted')
    })

    it('should hide the markdown editor container', function () {
      var editorInput = document.querySelector('.js-markdown-editor-input')
      expect(editorInput).toBeHidden()
    })

    it('should show the preview container', function () {
      var previewBody = document.querySelector('.js-markdown-preview-body')
      expect(previewBody).toBeVisible()
    })

    it('should show the default message in the preview container', function () {
      var previewBody = document.querySelector('.js-markdown-preview-body')
      expect(previewBody).toContainText('Nothing to preview')
    })
  })

  describe('when clicking "Edit markdown" button', function () {
    beforeEach(function () {
      document.querySelector('.js-markdown-edit-button').click()
    })

    it('should show the editor toolbar', function () {
      var toolbar = document.querySelector('.app-c-markdown-editor__toolbar')
      expect(toolbar).toBeVisible()
    })

    it('should mark the edit markdown button as selected', function () {
      var editButton = document.querySelector('.js-markdown-edit-button')
      expect(editButton).toHaveClass('app-c-markdown-editor__button--muted')
    })

    it('should not mark the preview markdown button as selected', function () {
      var previewButton = document.querySelector('.js-markdown-preview-button')
      expect(previewButton).not.toHaveClass('app-c-markdown-editor__button--muted')
    })

    it('should show the markdown editor container', function () {
      var editorInput = document.querySelector('.js-markdown-editor-input')
      expect(editorInput).toBeVisible()
    })

    it('should hide the preview container', function () {
      var previewBody = document.querySelector('.js-markdown-preview-body')
      expect(previewBody).toBeHidden()
    })

    it('should hide the default message in the preview container', function () {
      var previewBody = document.querySelector('.js-markdown-preview-body')
      expect(previewBody).not.toContainText('Nothing to preview')
    })
  })

  describe('when focusing the textarea', function () {
    it('should add focused class to container', function () {
      document.querySelector('.js-markdown-editor-input textarea').dispatchEvent(new window.Event('focus'))

      var container = document.querySelector('.app-c-markdown-editor__container')
      expect(container).toHaveClass('app-c-markdown-editor__container--focused')
    })

    it('should trigger a focus event on component', function () {
      var container = document.querySelector('.app-c-markdown-editor')
      spyOnEvent(container, 'focus')

      document.querySelector('.js-markdown-editor-input textarea').dispatchEvent(new window.Event('focus'))

      expect('focus').toHaveBeenTriggeredOn(container)
    })
  })

  describe('when blurring the textarea', function () {
    it('should remove focused class to container', function () {
      var container = document.querySelector('.app-c-markdown-editor__container')
      container.classList.add('app-c-markdown-editor__container--focused')

      document.querySelector('.js-markdown-editor-input textarea').dispatchEvent(new window.Event('blur'))
      expect(container).not.toHaveClass('app-c-markdown-editor__container--focused')
    })
  })
})
