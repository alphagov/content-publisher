/* global describe beforeEach afterEach it expect */
/* global MarkdownEditor */

describe('Markdown editor component', function () {
  'use strict'

  var container

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML =
      '<div class="app-c-markdown-editor" data-module="markdown-editor" data-govspeak-path="#">' +
        '<label for="markdown-editor" class="gem-c-label govuk-label ">Body</label>' +
        '<div class="app-c-markdown-editor__container js-markdown-editor__container">' +
          '<div class="app-c-markdown-editor__head js-markdown-editor__head">' +
            '<div class="app-c-markdown-editor__preview-toggle">' +
              '<button type="button" class="app-c-markdown-editor__button app-c-markdown-editor__button--muted js-markdown-edit-button">Edit markdown</button>' +
              '<button type="button" class="app-c-markdown-editor__button js-markdown-preview-button">Preview markdown</button>' +
            '</div>' +
            '<div class="app-c-markdown-editor__toolbar">' +
              '<markdown-toolbar class="app-c-markdown-editor__toolbar-group" for="markdown-editor">' +
                '<md-header-2 class="app-c-markdown-editor__toolbar-button">' +
                  '<i class="app-c-markdown-editor__toolbar-icon app-c-markdown-editor__toolbar-icon--heading-2" title="Heading level 2" aria-hidden="true"></i>' +
                  '<span class="govuk-visually-hidden">Heading level 2</span>' +
                '</md-header-2>' +
                '<md-header-3 class="app-c-markdown-editor__toolbar-button">' +
                  '<i class="app-c-markdown-editor__toolbar-icon app-c-markdown-editor__toolbar-icon--heading-3" title="Heading level 3" aria-hidden="true"></i>' +
                  '<span class="govuk-visually-hidden">Heading level 3</span>' +
                '</md-header-3>' +
                '<md-link class="app-c-markdown-editor__toolbar-button">' +
                  '<i class="app-c-markdown-editor__toolbar-icon app-c-markdown-editor__toolbar-icon--link" title="Link" aria-hidden="true"></i>' +
                  '<span class="govuk-visually-hidden">Link</span>' +
                '</md-link>' +
                '<md-quote class="app-c-markdown-editor__toolbar-button">' +
                  '<i class="app-c-markdown-editor__toolbar-icon app-c-markdown-editor__toolbar-icon--blockquote" title="Blockquote" aria-hidden="true"></i>' +
                  '<span class="govuk-visually-hidden">Blockquote</span>' +
                '</md-quote>' +
                '<md-ordered-list class="app-c-markdown-editor__toolbar-button">' +
                  '<i class="app-c-markdown-editor__toolbar-icon app-c-markdown-editor__toolbar-icon--numbered-list" title="Numbered list" aria-hidden="true"></i>' +
                  '<span class="govuk-visually-hidden">Numbered list</span>' +
                '</md-ordered-list>' +
                '<md-unordered-list class="app-c-markdown-editor__toolbar-button">' +
                  '<i class="app-c-markdown-editor__toolbar-icon app-c-markdown-editor__toolbar-icon--bullets" title="Bullets" aria-hidden="true"></i>' +
                  '<span class="govuk-visually-hidden">Bullets</span>' +
                '</md-unordered-list>' +
              '</markdown-toolbar>' +
            '</div>' +
          '</div>' +
          '<div class="app-c-markdown-editor__input js-markdown-editor-input">' +
            '<div class="govuk-form-group">' +
              '<textarea name="markdown-editor" class="gem-c-textarea govuk-textarea" id="markdown-editor" rows="5" spellcheck="true"></textarea>' +
            '</div>' +
          '</div>' +
          '<div class="app-c-markdown-editor__preview js-markdown-preview-body">' +
            '<div class="gem-c-govspeak govuk-govspeak ">' +
              '<div class="govuk-textarea"></div>' +
            '</div>' +
          '</div>' +
        '</div>' +
      '</div>'

    document.body.appendChild(container)
    var element = document.querySelector('[data-module="markdown-editor"]')
    new MarkdownEditor(element).init()
  })

  afterEach(function () {
    document.body.removeChild(container)
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
      document.querySelector('.js-markdown-editor-input textarea').focus()

      var container = document.querySelector('.app-c-markdown-editor__container')
      expect(container).toHaveClass('app-c-markdown-editor__container--focused')
    })

    it('should trigger a focus event on component', function () {
      var container = document.querySelector('.app-c-markdown-editor')
      spyOnEvent(container, 'focus')

      document.querySelector('.js-markdown-editor-input textarea').focus()

      expect('focus').toHaveBeenTriggeredOn(container)
    })

  })

  describe('when blurring the textarea', function () {
    it('should remove focused class to container', function () {
      document.querySelector('.js-markdown-editor-input textarea').blur()

      var container = document.querySelector('.app-c-markdown-editor__container')
      expect(container).not.toHaveClass('app-c-markdown-editor__container--focused')
    })
  })
})
