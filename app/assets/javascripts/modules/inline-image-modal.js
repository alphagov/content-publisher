function InlineImageModal ($module) {
  this.$module = $module
  this.$modal = document.getElementById('modal')
  this.workflow = new window.ModalWorkflow(this.$modal)
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

InlineImageModal.prototype.render = function (response) {
  response
    .then(this.renderSuccess.bind(this))
    .catch(this.renderError.bind(this))
}

InlineImageModal.prototype.renderError = function (result) {
  window.Raven.captureException(result)
  console.error(result)
  this.$multiSectionViewer.showStaticSection('error')
}

InlineImageModal.prototype.renderSuccess = function (result) {
  this.$multiSectionViewer.showDynamicSection(result.body)
  this.workflow.overrideActions(this.performAction.bind(this))
  this.workflow.initComponents()
}

InlineImageModal.prototype.insertSnippet = function (item) {
  var editor = this.$module.closest('[data-module="markdown-editor"]')
  editor.selectionReplace(item.dataset.modalData, { surroundWithNewLines: true })
}

InlineImageModal.prototype.performAction = function (item) {
  var handlers = {
    'open': function () {
      this.$modal.resize('wide')
      this.$modal.open()
      this.render(window.ModalFetch.getLink(item))
    },
    'insert': function () {
      this.$modal.close()
      this.insertSnippet(item)
    },
    'upload': function () {
      this.render(window.ModalFetch.postForm(item))
    },
    'cropBack': function () {
      this.render(window.ModalFetch.getLink(item))
    },
    'metaBack': function () {
      this.render(window.ModalFetch.getLink(item))
    },
    'crop': function () {
      this.render(window.ModalFetch.postForm(item))
    },
    'delete': function () {
      this.render(window.ModalFetch.postForm(item))
    },
    'meta': function () {
      this.render(window.ModalFetch.postForm(item))
    },
    'edit': function () {
      this.render(window.ModalFetch.getLink(item))
    },
    'metaInsert': function () {
      window.ModalFetch.postForm(item)
        .then(function (result) {
          if (result.unprocessableEntity) {
            this.renderSuccess(result)
          } else {
            this.$modal.close()
            this.insertSnippet(item)
          }
        }.bind(this))
        .catch(this.renderError.bind(this))
    }
  }

  this.$modal.focusDialog()
  this.$multiSectionViewer.showStaticSection('loading')
  handlers[item.dataset.modalAction].bind(this)()
}

var element = document.querySelector('[data-module="inline-image-modal"]')
new InlineImageModal(element).init()
