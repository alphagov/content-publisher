function ContactEmbedModal ($module) {
  this.$module = $module
  this.$modal = document.getElementById('modal')
}

ContactEmbedModal.prototype.init = function () {
  if (!this.$module || !this.$modal) {
    return
  }

  this.workflow = new window.ModalWorkflow(
    this.$modal,
    this.actionCallback.bind(this)
  )

  this.editor = new window.ModalEditor(this.$module)

  this.$module.addEventListener('click', function (event) {
    event.preventDefault()
    this.workflow.performAction(this.$module)
  }.bind(this))
}

ContactEmbedModal.prototype.actionCallback = function (item) {
  var handlers = {
    'open': function () {
      this.$modal.resize('narrow')
      this.$modal.open()
      this.workflow.render(window.ModalFetch.getLink(item))
    },
    'insert': function () {
      window.ModalFetch.postForm(item)
        .then(function (result) {
          if (result.unprocessableEntity) {
            this.workflow.renderSuccess(result)
          } else {
            this.$modal.close()
            this.editor.insertBlock(result.body)
          }
        }.bind(this))
        .catch(this.workflow.renderError)
    }
  }

  handlers[item.dataset.modalAction].bind(this)()
}

var element = document.querySelector('[data-module="contact-embed-modal"]')
new ContactEmbedModal(element).init()
