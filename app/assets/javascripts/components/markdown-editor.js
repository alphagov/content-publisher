/* global $ */
//= require markdown-toolbar-element/dist/index.umd.js
//= require paste-html-to-govspeak/dist/paste-html-to-markdown.js

window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function MarkdownEditor () { }

  MarkdownEditor.prototype.start = function ($module) {
    this.$module = $module[0]
    this.$head = this.$module.querySelector('.js-markdown-editor__head')
    this.$container = this.$module.querySelector('.js-markdown-editor__container')
    this.$input = this.$module.querySelector('textarea')
    this.$preview = this.$module.querySelector('.js-markdown-preview-body .govuk-textarea')
    this.$previewButton = this.$module.querySelector('.js-markdown-preview-button')
    this.$editButton = this.$module.querySelector('.js-markdown-edit-button')
    this.$editorInput = this.$module.querySelector('.js-markdown-editor-input')
    this.$previewBody = this.$module.querySelector('.js-markdown-preview-body')
    this.$toolbar = document.querySelector('.app-c-markdown-guidance')
    this.$editorToolbar = document.querySelector('.app-c-markdown-editor__toolbar')
    this.$module.selectionReplace = this.handleSelectionReplace.bind(this)

    // Enable toggle bar
    this.$head.style.display = 'block'

    // Handle button events
    this.$previewButton.addEventListener('click', this.handlePreviewButton.bind(this))
    this.$editButton.addEventListener('click', this.handleEditButton.bind(this))

    // Reflect focus events
    this.reflectFocusStateToContainer(this.$input, this.$container)
    this.bubbleFocusEventToComponent(this.$input)
    this.bubbleFocusEventToComponent(this.$editButton)
    this.bubbleFocusEventToComponent(this.$previewButton)

    // Convert pasted HTML to govspeak. Behind a pre-release feature flag.
    if (this.$input.dataset.pasteHtmlToGovspeak === 'true') {
      this.$input.addEventListener('paste', window.pasteHtmlToGovspeak.pasteListener)
    }
  }

  MarkdownEditor.prototype.handleSelectionReplace = function (text, options) {
    options = Object.assign({
      surroundWithNewLines: false
    }, options)

    var selectionStart = this.$input.selectionStart + text.length
    this.$input.focus()

    if (options.surroundWithNewLines) {
      var newlines = window.MarkdownToolbarElement.newlinesToSurroundSelectedText(this.$input)
      // despite what logic might tell you, this is supposed to be append as a
      // prefix and prepend as a suffix. Perhaps the github logic was that you
      // append new lines to the text before selection and prepend it to text
      // after selection.
      text = newlines.newlinesToAppend + text + newlines.newlinesToPrepend
    }

    window.MarkdownToolbarElement.insertText(
      this.$input,
      { text: text, selectionStart: selectionStart, selectionEnd: selectionStart }
    )
  }

  MarkdownEditor.prototype.handlePreviewButton = function (event) {
    event.preventDefault()

    // Disable action if muted
    if (this.$previewButton.classList.contains('app-c-markdown-editor__button--muted')) {
      return
    }

    // Mirror textarea's height
    this.$preview.style.height = this.$input.offsetHeight + this.$editorToolbar.offsetHeight + 'px'

    // Clear previous preview
    this.$preview.innerHTML = ''
    this.$preview.classList.remove('app-c-markdown-editor__govspeak--rendered')

    if (!this.$input.value) {
      this.$preview.innerHTML = 'Nothing to preview'
      this.toggleElements()
      return
    }

    if (window.FetchContent) {
      window.FetchContent.govspeak(this.$input.value, this.$module.getAttribute('data-govspeak-path'))
        .then(function (text) {
          this.$preview.innerHTML = text
          this.setTargetBlank(this.$preview)
          this.$preview.classList.add('app-c-markdown-editor__govspeak--rendered')
          window.GOVUK.modules.start($(this.$preview))
          window.GOVUKFrontend.initAll(this.$preview)
        }.bind(this))
        .catch(function () {
          this.$preview.innerHTML = 'Error previewing content'
          this.$preview.classList.add('app-c-markdown-editor__govspeak--rendered')
        }.bind(this))
    }

    this.toggleElements()
  }

  MarkdownEditor.prototype.handleEditButton = function (event) {
    event.preventDefault()

    // Disable action if muted
    if (this.$editButton.classList.contains('app-c-markdown-editor__button--muted')) {
      return
    }

    this.toggleElements()
  }

  MarkdownEditor.prototype.toggleElements = function () {
    this.$editButton.classList.toggle('app-c-markdown-editor__button--muted')
    this.$previewButton.classList.toggle('app-c-markdown-editor__button--muted')
    this.toggle(this.$editorInput)
    this.toggle(this.$previewBody)
    if (this.$toolbar) {
      this.toggle(this.$toolbar)
    }
    if (this.$editorToolbar) {
      this.toggle(this.$editorToolbar)
    }
  }

  MarkdownEditor.prototype.toggle = function (element) {
    // Evaluate `display` property coming from either CSS or JavaScript
    if (element.ownerDocument.defaultView.getComputedStyle(element, null).display === 'none') {
      element.style.display = 'block'
    } else {
      element.style.display = 'none'
    }
  }

  // Set target="_blank" to anchors inside the container
  MarkdownEditor.prototype.setTargetBlank = function (container) {
    if (container) {
      var anchors = container.querySelectorAll('a')
      anchors.forEach(function (anchor) {
        anchor.setAttribute('target', '_blank')
      })
    }
  }

  // Reflect focus and blur events to component
  MarkdownEditor.prototype.bubbleFocusEventToComponent = function (element) {
    var $module = this.$module
    element.addEventListener('focus', function (event) {
      $module.dispatchEvent(new window.Event('focus'))
    }, true)
    element.addEventListener('blur', function (event) {
      $module.dispatchEvent(new window.Event('blur'))
    }, true)
  }

  // Reflect focus and blur element state to container
  MarkdownEditor.prototype.reflectFocusStateToContainer = function (element, container) {
    element.addEventListener('focus', function (event) {
      container && container.classList.add('app-c-markdown-editor__container--focused')
    }, true)
    element.addEventListener('blur', function (event) {
      container && container.classList.remove('app-c-markdown-editor__container--focused')
    }, true)
  }

  Modules.MarkdownEditor = MarkdownEditor
})(window.GOVUK.Modules)
