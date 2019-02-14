function ModalManager (trigger) {
  this.$trigger = trigger
  var id = trigger.dataset.modalId
  this.$modal = document.getElementById(id)
}

ModalManager.prototype.init = function () {
  this.$trigger.addEventListener('click', this.handleModalOpen.bind(this))
}

ModalManager.prototype.handleModalOpen = function (event) {
  event.preventDefault()
  this.$modal.open()

  var $modalTitle = this.$modal.querySelector('.app-c-modal-dialogue__title')
  var $modalBody = this.$modal.querySelector('.app-c-modal-dialogue__body')
  var $module = this

  this.fetchModalContent().then(function (text) {
    $modalTitle.innerHTML = $module.$trigger.dataset.modalTitle
    $modalBody.innerHTML = text
    $module.overrideActions($modalBody)
  })
}

ModalManager.prototype.fetchModalContent = function () {
  var url = this.$trigger.dataset.modalUrl
  var controller = new window.AbortController()
  var options = { credentials: 'include', signal: controller.signal }
  setTimeout(function () { controller.abort() }, 5000)

  return window.fetch(url, options)
    .then(function (response) { return response.text() })
}

ModalManager.prototype.performAction = function (action) {
  var actions = {
    'insert': function () {
      var editor = this.$trigger.closest('[data-module="markdown-editor"]')
      this.$modal.close()
      editor.selectionReplace(action.dataset.modalData)
    },
    'upload': function () {
      console.log('hi')
    }
  }

  actions[action.dataset.modalAction].bind(this)()
}

ModalManager.prototype.overrideActions = function (modalBody) {
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
new ModalManager(element).init()
