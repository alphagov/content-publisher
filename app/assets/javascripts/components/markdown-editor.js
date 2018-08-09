//= require vendor/@webcomponents/webcomponentsjs/webcomponents-loader.js
//= require vendor/@github/markdown-toolbar-element/dist/index.umd.js
//= require vendor/marked/lib/marked.js

function MarkdownEditor ($module) {
  this.$module = $module
  this.$input = $module.querySelector('textarea')
  this.$preview = $module.querySelector('.js-preview-body .govuk-textarea')
  this.$previewButton = $module.querySelector('.js-preview-button')
  this.$editButton = $module.querySelector('.js-edit-button')
  this.$editorInput = $module.querySelector('.js-editor-input')
  this.$previewBody = $module.querySelector('.js-preview-body')
}

MarkdownEditor.prototype.init = function () {
  var $module = this.$module

  // Save bounded functions to use when removing event listeners during teardown
  $module.boundPreviewButtonClick = this.handlePreviewButton.bind(this)
  $module.boundEditButtonClick = this.handleEditButton.bind(this)

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

  // Render markdown
  window.marked(text, function (err, content) {
    if (err) {
      $preview.innerHTML = 'Error previewing content'
      throw err
    } else {
      $preview.innerHTML = content
    }
  })

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
