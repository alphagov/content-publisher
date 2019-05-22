function InlineAttachmentModal ($module) {
  this.$module = $module
  this.$modal = document.getElementById('modal')
  this.workflow = new window.ModalWorkflow(this.$modal)
}

InlineAttachmentModal.prototype.init = function () {
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

InlineAttachmentModal.prototype.render = function (response) {
  response
    .then(this.renderSuccess.bind(this))
    .catch(this.renderError.bind(this))
}

InlineAttachmentModal.prototype.renderError = function (result) {
  window.Raven.captureException(result)
  console.error(result)
  this.$multiSectionViewer.showStaticSection('error')
}

InlineAttachmentModal.prototype.renderSuccess = function (result) {
  this.$multiSectionViewer.showDynamicSection(result.body)
  this.workflow.overrideActions(this.performAction.bind(this))
  this.workflow.initComponents()
}

InlineAttachmentModal.prototype.performAction = function (item) {
  var handlers = {
    'open': function () {
      this.$modal.resize('narrow')
      this.$modal.open()
      this.render(window.ModalFetch.getLink(item))
    },
    'upload': function () {
      this.render(window.ModalFetch.postForm(item))
    },
    'insert': function () {
      this.render(window.ModalFetch.getLink(item))
    },
    'delete': function () {
      this.render(window.ModalFetch.postForm(item))
    },
    'edit': function () {
      this.render(window.ModalFetch.getLink(item))
    },
    'update': function () {
      this.render(window.ModalFetch.postForm(item))
    },
    'back': function () {
      this.render(window.ModalFetch.getLink(item))
    }
  }

  this.$modal.focusDialog()
  this.$multiSectionViewer.showStaticSection('loading')
  handlers[item.dataset.modalAction].bind(this)()
}

var element = document.querySelector('[data-module="inline-attachment-modal"]')
new InlineAttachmentModal(element).init()
