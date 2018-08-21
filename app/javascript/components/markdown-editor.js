import '@webcomponents/webcomponentsjs/webcomponents-bundle'
import 'components/markdown-toolbar'
import marked from 'marked'

function MarkdownEditor ($module) {
  this.$module = $module
  this.$head = $module.querySelector('.js-markdown-editor__head')
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
  this.$head.style.display = 'block'

  // Handle events
  this.$previewButton.addEventListener('click', $module.boundPreviewButtonClick)
  this.$editButton.addEventListener('click', $module.boundEditButtonClick)
}

MarkdownEditor.prototype.handlePreviewButton = function (event) {
  event.preventDefault()

  // Disable action if muted
  if (this.$previewButton.classList.contains('app-c-markdown-editor__button--muted')) {
    return
  }

  var $preview = this.$preview
  var text = this.$input.value

  // Mirror textarea's height
  $preview.style.height = this.$input.offsetHeight + 'px'

  if (text) {
    // Render markdown
    marked(
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
}

MarkdownEditor.prototype.toggle = function (element) {
  // Evaluate `display` property coming from either CSS or JavaScript
  if (element.ownerDocument.defaultView.getComputedStyle(element, null).display === 'none') {
    element.style.display = 'block'
  } else {
    element.style.display = 'none'
  }
}

export default MarkdownEditor
