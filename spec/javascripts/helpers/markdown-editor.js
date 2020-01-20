/* eslint-env jquery */
/* global GOVUK */

window.buildMarkdownEditor = function buildMarkdownEditor () {
  var markdownEditor = document.createElement('div')
  markdownEditor.className = 'app-c-markdown-editor'
  markdownEditor.dataset.module = 'markdown-editor'
  markdownEditor.dataset.govspeakPath = '#'

  markdownEditor.innerHTML =
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
    '</div>'

  // The markdown component can hit a number of errors if it is initialised
  // before attached to the DOM.
  document.body.appendChild(markdownEditor)
  new GOVUK.Modules.MarkdownEditor().start($(markdownEditor))
  return markdownEditor
}

window.removeMarkdownEditor = function removeMarkdownEditor () {
  var markdownEditor = document.querySelector('.app-c-markdown-editor')
  if (markdownEditor) {
    markdownEditor.parentNode.removeChild(markdownEditor)
  }
}
