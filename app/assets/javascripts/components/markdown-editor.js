//= require vendor/@webcomponents/webcomponentsjs/webcomponents-loader.js
//= require vendor/@github/markdown-toolbar-element/dist/index.umd.js
//= require vendor/marked/lib/marked.js

function MarkdownEditor ($module) {
  this.$module = $module
  this.$toggleBar = $module.querySelector('.js-markdown-toggle-bar')
  this.$input = $module.querySelector('textarea')
  this.$preview = $module.querySelector('.js-markdown-preview-body .govuk-textarea')
  this.$previewButton = $module.querySelector('.js-markdown-preview-button')
  this.$editButton = $module.querySelector('.js-markdown-edit-button')
  this.$editorInput = $module.querySelector('.js-markdown-editor-input')
  this.$previewBody = $module.querySelector('.js-markdown-preview-body')
}

MarkdownEditor.prototype.init = function () {
  var $module = this.$module

  // Save bounded functions to use when removing event listeners during teardown
  $module.boundPreviewButtonClick = this.handlePreviewButton.bind(this)
  $module.boundEditButtonClick = this.handleEditButton.bind(this)

  // Enable toggle bar
  this.$toggleBar.style.display = 'block'

  // Handle events
  this.$previewButton.addEventListener('click', $module.boundPreviewButtonClick)
  this.$editButton.addEventListener('click', $module.boundEditButtonClick)
}

MarkdownEditor.prototype.handlePreviewButton = function (event) {
  event.preventDefault()

  var $preview = this.$preview
  var text = this.$input.value

  // Mirror textarea's height
  $preview.style.height = this.$input.offsetHeight + 'px'

  if (text) {
    // Render markdown
    window.marked(
      text,
      function (err, content) {
        if (err) {
          $preview.innerHTML = 'Error previewing content'
          throw err
        } else {
          $preview.innerHTML = content
        }
      }
    )
  } else {
    $preview.innerHTML = 'Nothing to preview'
  }
  this.toggleElements()
}

MarkdownEditor.prototype.handleEditButton = function (event) {
  event.preventDefault()

  this.toggleElements()
}

MarkdownEditor.prototype.toggleElements = function () {
  this.toggle(this.$editButton)
  this.toggle(this.$previewButton)
  this.toggle(this.$editorInput)
  this.toggle(this.$previewBody)
}

MarkdownEditor.prototype.toggle = function (element) {
  // Evaluate `display` property coming from either CSS or JavaScript
  if (element.ownerDocument.defaultView.getComputedStyle(element, null).display === 'none') {
    element.style.display = 'block'
  } else {
    element.style.display = 'none'
  }
}

// Initialise markdown editor
var $govspeak = document.querySelector('[data-module="markdown-editor"]')
if ($govspeak) {
  new MarkdownEditor($govspeak).init()
}
