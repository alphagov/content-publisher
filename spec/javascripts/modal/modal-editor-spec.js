/* eslint-env jasmine */
/* global ModalEditor, buildMarkdownEditor, removeMarkdownEditor */

describe('ModalEditor', function () {
  'use strict'

  var modalEditor, markdownEditor

  beforeEach(function () {
    markdownEditor = buildMarkdownEditor()
    // we'll simulate this being initialised by a control by selecting one of
    // the toolbar buttons
    var control = markdownEditor.querySelector('.app-c-markdown-editor__toolbar-button')
    modalEditor = new ModalEditor(control)
    spyOn(markdownEditor, 'selectionReplace')
  })

  afterEach(function () {
    removeMarkdownEditor()
  })

  describe('modalEditor.insertBlock', function () {
    it('delegates to markdownEditor to insert text surrounded by new lines', function () {
      modalEditor.insertBlock('content')
      expect(markdownEditor.selectionReplace).toHaveBeenCalledWith(
        'content',
        { surroundWithNewLines: true }
      )
    })
  })

  describe('modalEditor.insertInline', function () {
    it('delegates to markdownEditor to insert text without surrounding it with new lines', function () {
      modalEditor.insertInline('content')
      expect(markdownEditor.selectionReplace).toHaveBeenCalledWith('content')
    })
  })
})
