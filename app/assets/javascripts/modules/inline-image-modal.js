/* global $ */

function InlineImageModal ($module) {
  this.$module = $module
  this.$modal = document.getElementById('modal')
}

InlineImageModal.prototype.init = function () {
  if (!this.$module || !this.$modal) {
    return
  }

  this.$multiSectionViewer = this.$modal
    .querySelector('[data-module="multi-section-viewer"]')

  this.$module.addEventListener('click', function (event) {
    event.preventDefault()
    this.performAction(this.$module)
  }.bind(this))
}

InlineImageModal.prototype.renderResponse = function (response) {
  response
    .then(function (result) {
      this.$multiSectionViewer.showDynamicSection(result.body)
      this.overrideActions()
      this.initComponents()
    }.bind(this))
    .catch(function (result) {
      this.$multiSectionViewer.showStaticSection('error')
    }.bind(this))
}

InlineImageModal.prototype.insertSnippet = function (item) {
  var editor = this.$module.closest('[data-module="markdown-editor"]')
  editor.selectionReplace(item.dataset.modalData)
}

InlineImageModal.prototype.performAction = function (item) {
  var handlers = {
    'open': function () {
      this.$modal.open()
      this.renderResponse(window.ModalFetch.getLink(item))
    },
    'insert': function () {
      this.$modal.close()
      this.insertSnippet(item)
    },
    'upload': function () {
      this.renderResponse(window.ModalFetch.postForm(item))
    },
    'cropBack': function () {
      this.renderResponse(window.ModalFetch.getLink(item))
    },
    'metaBack': function () {
      this.renderResponse(window.ModalFetch.getLink(item))
    },
    'crop': function () {
      this.renderResponse(window.ModalFetch.postForm(item))
    },
    'delete': function () {
      this.renderResponse(window.ModalFetch.postForm(item))
    },
    'meta': function () {
      this.renderResponse(window.ModalFetch.postForm(item))
    },
    'metaInsert': function () {
      window.ModalFetch.postForm(item)
        .then(function (result) {
          if (result.done) {
            this.$modal.close()
            this.insertSnippet(item)
          } else {
            this.$multiSectionViewer.showDynamicSection(result.body)
            this.overrideActions()
            this.initComponents()
          }
        }.bind(this))
        .catch(function (result) {
          this.$multiSectionViewer.showStaticSection('error')
        }.bind(this))
    },
    'edit': function () {
      this.renderResponse(window.ModalFetch.getLink(item))
    }
  }

  this.$modal.focusDialog()
  this.$multiSectionViewer.showStaticSection('loading')
  handlers[item.dataset.modalAction].bind(this)()
}

InlineImageModal.prototype.initComponents = function () {
  window.GOVUK.modules.start($(this.$modal))

  // TODO: change ErrorSummary so it just focusses when it's initialised
  var $errorSummary = document.querySelector('[data-module="error-summary"]')

  if (!$errorSummary) {
    return
  }

  $errorSummary.focus()
}

InlineImageModal.prototype.overrideActions = function () {
  var formItems = this.$modal.querySelectorAll('form[data-modal-action]')
  var linkItems = this.$modal.querySelectorAll('a[data-modal-action]')

  linkItems.forEach(function (item) {
    item.addEventListener('click', function (event) {
      event.preventDefault()
      this.performAction(item)
    }.bind(this))
  }.bind(this))

  formItems.forEach(function (item) {
    item.addEventListener('submit', function (event) {
      event.preventDefault()
      this.performAction(item)
    }.bind(this))
  }.bind(this))
}

var element = document.querySelector('[data-module="inline-image-modal"]')
new InlineImageModal(element).init()
