function AddInlineImage (trigger) {
  this.$trigger = trigger
  var id = trigger.dataset.modalId
  this.$modal = document.getElementById(id)
}

AddInlineImage.prototype.init = function () {
  this.$trigger.addEventListener('click', this.handleModalOpen.bind(this))
}

AddInlineImage.prototype.handleModalOpen = function (event) {
  event.preventDefault()
  this.$modal.open()

  var $modalBody = this.$modal.querySelector('.app-c-modal-dialogue__body')
  var $module = this

  this.fetchModalContent()
    .then(function (text) {
      $modalBody.innerHTML = text
      $module.overrideActions($modalBody)
    })
    .catch(function (result) {
      if (result) {
        $modalTitle.innerHTML = ''
        $modalBody.innerHTML = '<p class="govuk-error-message">' + result + '</p>'
      }
    })
}

AddInlineImage.prototype.fetchModalContent = function () {
  var url = this.$trigger.dataset.modalUrl
  var controller = new window.AbortController()
  var options = { credentials: 'include', signal: controller.signal }
  setTimeout(function () { controller.abort() }, 5000)

  return window.fetch(url, options)
    .then(function (response) {
      if (!response.ok) {
        return window.Promise.reject('Unable to render the content.')
      }
      return response.text()
    })
}

AddInlineImage.prototype.performAction = function (action) {
  var actions = {
    'insert': function () {
      var editor = this.$trigger.closest('[data-module="markdown-editor"]')
      this.$modal.close()
      editor.selectionReplace(action.dataset.modalData)
    }
  }

  actions[action.dataset.modalAction].bind(this)()
}

AddInlineImage.prototype.overrideActions = function (modalBody) {
  var actions = modalBody.querySelectorAll('[data-modal-action]')
  var $module = this

  actions.forEach(function (action) {
    action.addEventListener('click', function (event) {
      event.preventDefault()
      $module.performAction(action)
    })
  })
}

var element = document.querySelector('[data-module="add-inline-image"]')
new AddInlineImage(element).init()
