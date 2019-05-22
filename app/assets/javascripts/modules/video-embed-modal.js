function VideoEmbedModal ($module) {
  this.$module = $module
  this.$modal = document.getElementById('modal')
  this.workflow = new window.ModalWorkflow(this.$modal)
}

VideoEmbedModal.prototype.init = function () {
  if (!this.$module || !this.$modal) {
    return
  }

  this.$multiSectionViewer = this.$modal
    .querySelector('[data-module="multi-section-viewer"]')

  this.editor = new window.ModalEditor(this.$module)

  this.$module.addEventListener('click', function (event) {
    event.preventDefault()
    this.performAction(this.$module)
  }.bind(this))
}

VideoEmbedModal.prototype.render = function (response) {
  response
    .then(this.renderSuccess.bind(this))
    .catch(this.renderError.bind(this))
}

VideoEmbedModal.prototype.renderError = function (result) {
  window.Raven.captureException(result)
  console.error(result)
  this.$multiSectionViewer.showStaticSection('error')
}

VideoEmbedModal.prototype.renderSuccess = function (result) {
  this.$multiSectionViewer.showDynamicSection(result.body)
  this.workflow.overrideActions(this.performAction.bind(this))
  this.workflow.initComponents()
}

VideoEmbedModal.prototype.performAction = function (item) {
  var handlers = {
    'open': function () {
      this.$modal.resize('narrow')
      this.$modal.open()
      this.render(window.ModalFetch.getLink(item))
    },
    'insert': function () {
      window.ModalFetch.postForm(item)
        .then(function (result) {
          if (result.unprocessableEntity) {
            this.renderSuccess(result)
          } else {
            this.$modal.close()
            this.editor.insertBlock(result.body)
          }
        }.bind(this))
        .catch(this.renderError.bind(this))
    }
  }

  this.$modal.focusDialog()
  this.$multiSectionViewer.showStaticSection('loading')
  handlers[item.dataset.modalAction].bind(this)()
}

var element = document.querySelector('[data-module="video-embed-modal"]')
new VideoEmbedModal(element).init()
