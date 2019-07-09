function InlineImageModal ($module) {
  this.$module = $module
  this.$modal = document.getElementById('modal')
}

InlineImageModal.prototype.init = function () {
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

InlineImageModal.prototype.actionCallback = function (item) {
  var handlers = {
    'open': function () {
      this.$modal.resize('wide')
      this.$modal.open()
      this.workflow.render(window.ModalFetch.getLink(item))
    },
    'insert': function () {
      this.$modal.close()
      this.editor.insertBlock(item.dataset.modalData)
    },
    'upload': function () {
      this.workflow.render(window.ModalFetch.postForm(item))
    },
    'cropBack': function () {
      this.workflow.render(window.ModalFetch.getLink(item))
    },
    'metaBack': function () {
      this.workflow.render(window.ModalFetch.getLink(item))
    },
    'crop': function () {
      this.workflow.render(window.ModalFetch.postForm(item))
    },
    'delete': function () {
      this.workflow.render(window.ModalFetch.postForm(item))
    },
    'meta': function () {
      this.workflow.render(window.ModalFetch.postForm(item))
    },
    'edit': function () {
      this.workflow.render(window.ModalFetch.getLink(item))
    },
    'metaInsert': function () {
      window.ModalFetch.postForm(item)
        .then(function (result) {
          if (result.unprocessableEntity) {
            this.workflow.renderSuccess(result)
          } else {
            this.$modal.close()
            this.editor.insertBlock(item.dataset.modalData)
          }
        }.bind(this))
        .catch(this.workflow.renderError)
    }
  }

  handlers[item.dataset.modalAction].bind(this)()
}

var element = document.querySelector('[data-module="inline-image-modal"]')
new InlineImageModal(element).init()
