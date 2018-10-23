/* global describe beforeEach afterEach it expect */
/* global MarkdownEditor */
var $ = window.jQuery

describe('Markdown editor component', function () {
  'use strict'

  var element

  beforeEach(function () {
    element = $(`
      <div class="app-c-markdown-editor" data-module="markdown-editor" data-govspeak-path="#">
        <label for="markdown-editor" class="gem-c-label govuk-label ">Body</label>
        <div class="app-c-markdown-editor__container">
          <div class="app-c-markdown-editor__head js-markdown-editor__head">
            <div class="app-c-markdown-editor__preview-toggle">
              <button type="button" class="app-c-markdown-editor__button app-c-markdown-editor__button--muted js-markdown-edit-button">Edit markdown</button>
              <button type="button" class="app-c-markdown-editor__button js-markdown-preview-button">Preview markdown</button>
            </div>
            <div class="app-c-markdown-editor__toolbar">
              <markdown-toolbar class="app-c-markdown-editor__toolbar-group" for="markdown-editor">
                <md-header-2 class="app-c-markdown-editor__toolbar-button">
                  <i class="app-c-markdown-editor__toolbar-icon app-c-markdown-editor__toolbar-icon--heading-2" title="Heading level 2" aria-hidden="true"></i>
                  <span class="govuk-visually-hidden">Heading level 2</span>
                </md-header-2>
                <md-header-3 class="app-c-markdown-editor__toolbar-button">
                  <i class="app-c-markdown-editor__toolbar-icon app-c-markdown-editor__toolbar-icon--heading-3" title="Heading level 3" aria-hidden="true"></i>
                  <span class="govuk-visually-hidden">Heading level 3</span>
                </md-header-3>
                <md-link class="app-c-markdown-editor__toolbar-button">
                  <i class="app-c-markdown-editor__toolbar-icon app-c-markdown-editor__toolbar-icon--link" title="Link" aria-hidden="true"></i>
                  <span class="govuk-visually-hidden">Link</span>
                </md-link>
                <md-quote class="app-c-markdown-editor__toolbar-button">
                  <i class="app-c-markdown-editor__toolbar-icon app-c-markdown-editor__toolbar-icon--blockquote" title="Blockquote" aria-hidden="true"></i>
                  <span class="govuk-visually-hidden">Blockquote</span>
                </md-quote>
                <md-ordered-list class="app-c-markdown-editor__toolbar-button">
                  <i class="app-c-markdown-editor__toolbar-icon app-c-markdown-editor__toolbar-icon--numbered-list" title="Numbered list" aria-hidden="true"></i>
                  <span class="govuk-visually-hidden">Numbered list</span>
                </md-ordered-list>
                <md-unordered-list class="app-c-markdown-editor__toolbar-button">
                  <i class="app-c-markdown-editor__toolbar-icon app-c-markdown-editor__toolbar-icon--bullets" title="Bullets" aria-hidden="true"></i>
                  <span class="govuk-visually-hidden">Bullets</span>
                </md-unordered-list>
              </markdown-toolbar>
            </div>
          </div>
          <div class="app-c-markdown-editor__input js-markdown-editor-input">
            <div class="govuk-form-group">
              <textarea name="markdown-editor" class="gem-c-textarea govuk-textarea" id="markdown-editor" rows="5" spellcheck="true"></textarea>
            </div>
          </div>
          <div class="app-c-markdown-editor__preview js-markdown-preview-body">
            <div class="gem-c-govspeak govuk-govspeak ">
              <div class="govuk-textarea"></div>
            </div>
          </div>
        </div>
      </div>
    `)
    $(document.body).append(element)
    new MarkdownEditor(element[0]).init()
  })

  afterEach(function () {
    element.remove()
    element = undefined
  })

  it('should show the editor header', function () {
    var head = $('.js-markdown-editor__head')
    expect(head.css('display')).toEqual('block')
  })

  it('should show the editor toolbar', function () {
    var toolbar = $('.app-c-markdown-editor__toolbar')
    expect(toolbar.css('display')).toEqual('block')
  })

  it('should show the markdown editor container', function () {
    var editorInput = $('.js-markdown-editor-input')
    expect(editorInput.css('display')).toEqual('block')
  })

  it('should hide the preview container', function () {
    var previewBody = $('.js-markdown-preview-body')
    expect(previewBody.css('display')).toEqual('none')
  })

  describe('when clicking "Preview markdown" button', function () {
    beforeEach(function () {
      $('.js-markdown-preview-button').click()
    })

    it('should hide the editor toolbar', function () {
      var toolbar = $('.app-c-markdown-editor__toolbar')
      expect(toolbar.css('display')).toEqual('none')
    })

    it('should not mark the edit markdown button as selected', function () {
      expect($('.js-markdown-edit-button').hasClass('app-c-markdown-editor__button--muted')).toEqual(false)
    })

    it('should mark the preview markdown button as selected', function () {
      expect($('.js-markdown-preview-button').hasClass('app-c-markdown-editor__button--muted')).toEqual(true)
    })

    it('should hide the markdown editor container', function () {
      var editorInput = $('.js-markdown-editor-input')
      expect(editorInput.css('display')).toEqual('none')
    })

    it('should show the preview container', function () {
      var previewBody = $('.js-markdown-preview-body')
      expect(previewBody.css('display')).toEqual('block')
    })

    it('should show the default message in the preview container', function () {
      var previewBody = $('.js-markdown-preview-body')
      expect(previewBody.html()).toContain('Nothing to preview')
    })
  })

  describe('when clicking "Edit markdown" button', function () {
    beforeEach(function () {
      $('.js-markdown-edit-button').click()
    })

    it('should show the editor toolbar', function () {
      var toolbar = $('.app-c-markdown-editor__toolbar')
      expect(toolbar.css('display')).toEqual('block')
    })

    it('should mark the edit markdown button as selected', function () {
      expect($('.js-markdown-edit-button').hasClass('app-c-markdown-editor__button--muted')).toEqual(true)
    })

    it('should not mark the preview markdown button as selected', function () {
      expect($('.js-markdown-preview-button').hasClass('app-c-markdown-editor__button--muted')).toEqual(false)
    })

    it('should show the markdown editor container', function () {
      var editorInput = $('.js-markdown-editor-input')
      expect(editorInput.css('display')).toEqual('block')
    })

    it('should hide the preview container', function () {
      var previewBody = $('.js-markdown-preview-body')
      expect(previewBody.css('display')).toEqual('none')
    })

    it('should hide the default message in the preview container', function () {
      var previewBody = $('.js-markdown-preview-body')
      expect(previewBody.html()).not.toContain('Nothing to preview')
    })
  })
})
