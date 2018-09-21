//= require components/markdown-toolbar

function MarkdownEditor ($module) {
  this.$module = $module
  this.$head = $module.querySelector('.js-markdown-editor__head')
  this.$input = $module.querySelector('textarea')
  this.$preview = $module.querySelector('.js-markdown-preview-body .govuk-textarea')
  this.$previewButton = $module.querySelector('.js-markdown-preview-button')
  this.$editButton = $module.querySelector('.js-markdown-edit-button')
  this.$editorInput = $module.querySelector('.js-markdown-editor-input')
  this.$previewBody = $module.querySelector('.js-markdown-preview-body')
  this.$toolbar = document.querySelector('.app-c-markdown-toolbar')
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

  // Mirror textarea's height
  this.$preview.style.height = this.$input.offsetHeight + 'px'

  // Clear previous preview
  this.$preview.innerHTML = ''
  this.$preview.classList.remove('app-c-markdown-editor__govspeak--rendered')

  if (!this.$input.value) {
    this.$preview.innerHTML = 'Nothing to preview'
    this.toggleElements()
    return
  }

  var $preview = this.$preview

  this.fetchGovspeakPreview(this.$input.value)
    .then(function (text) {
      $preview.innerHTML = text
    })
    .catch(function () {
      $preview.innerHTML = 'Error previewing content'
    })
    .finally(function () {
      $preview.classList.add('app-c-markdown-editor__govspeak--rendered')
    })

  this.setTargetBlank(this.$preview)
  this.toggleElements()
}

MarkdownEditor.prototype.fetchGovspeakPreview = function (text) {
  var path = this.$module.getAttribute('data-govspeak-path')
  var url = new URL(document.location.origin + path)

  var formData = new window.FormData()
  formData.append('govspeak', text)

  var controller = new window.AbortController()
  var options = { credentials: 'include', signal: controller.signal, method: 'POST', body: formData }
  setTimeout(function () { controller.abort() }, 5000)

  return window.fetch(url, options).then(function (response) { return response.text() })
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

var $govspeak = document.querySelector('[data-module="markdown-editor"]')
if ($govspeak) {
  new MarkdownEditor($govspeak).init()
}
