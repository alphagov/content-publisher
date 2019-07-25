function ContactsModal ($module) {
  this.$module = $module
  this.$modal = document.getElementById('modal')
}

ContactsModal.prototype.init = function () {
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

ContactsModal.prototype.actionCallback = function (item) {
  var handlers = {
    'open': function () {
      this.$modal.resize('narrow')
      this.$modal.open()
      this.workflow.render(window.ModalFetch.getLink(item))
    },
    'insert': function () {
      this.$modal.close()
      this.editor.insertBlock(item.dataset.modalData)
    }
  }

  handlers[item.dataset.modalAction].bind(this)()
}

var element = document.querySelector('[data-module="contacts-modal"]')
new ContactsModal(element).init()
