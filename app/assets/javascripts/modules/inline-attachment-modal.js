function InlineAttachmentModal ($module) {
  this.$module = $module
  this.$modal = document.getElementById('modal')
}

InlineAttachmentModal.prototype.init = function () {
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

InlineAttachmentModal.prototype.actionCallback = function (item) {
  var handlers = {
    'open': function () {
      this.$modal.resize('narrow')
      this.$modal.open()
      this.workflow.render(window.ModalFetch.getLink(item))
    },
    'upload': function () {
      this.workflow.render(window.ModalFetch.postForm(item))
    },
    'insert': function () {
      this.workflow.render(window.ModalFetch.getLink(item))
    },
    'delete': function () {
      this.workflow.render(window.ModalFetch.getLink(item))
    },
    'confirmDelete': function () {
      this.workflow.render(window.ModalFetch.postForm(item))
    },
    'edit': function () {
      this.workflow.render(window.ModalFetch.getLink(item))
    },
    'update': function () {
      this.workflow.render(window.ModalFetch.postForm(item))
    },
    'back': function () {
      this.workflow.render(window.ModalFetch.getLink(item))
    },
    'insert-attachment-block': function () {
      this.editor.insertBlock(item.dataset.modalData)
      this.$modal.close()
    },
    'insert-attachment-link': function () {
      this.editor.insertInline(item.dataset.modalData)
      this.$modal.close()
    }
  }

  handlers[item.dataset.modalAction].bind(this)()
}

var element = document.querySelector('[data-module="inline-attachment-modal"]')
new InlineAttachmentModal(element).init()
