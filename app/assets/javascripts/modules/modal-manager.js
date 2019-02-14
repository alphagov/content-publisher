function ModalManager () {
  this.$currentModal = null
}

ModalManager.prototype.init = function () {
  this.handleModalOpen()
}

ModalManager.prototype.getAction = function (action) {
  var actions = {
    'insert-image': this.insertImage
  }

  return actions[action]
}

ModalManager.prototype.handleModalOpen = function () {
  document.addEventListener('modalOpen', function (event) {
    this.$currentModal = event.target

    ModalManager.prototype.handleActionWithinModal(this.$currentModal)
  })
}

ModalManager.prototype.handleModalUpdate = function (currentModal) {
  // TODO: Replace markup
  ModalManager.prototype.handleActionWithinModal(currentModal)
}

ModalManager.prototype.getAllModals = function () {
  return document.querySelectorAll('[data-module="modal-dialogue"]')
}

ModalManager.prototype.handleActionWithinModal = function (modal) {
  // Read form address (data-modal-form-action="/contacts-endpoint") to know where to make a call
  var $form = modal.querySelector('[data-modal-form-action]')

  // Read primary action (data-modal-action="Insert contact") that need to be overwritten in terms of text and or events
  var $button = modal.querySelector('[data-modal-action]')
  var modalAction = $button.dataset.modalAction

  if (modalAction === 'submit') {
    // TODO: POST form data to an endpoint
    this.fetchModalContent($form, modal)
  } else if (ModalManager.prototype.getAction(modalAction)) {
    // TODO: Trigger a JavaScript function - move this to a separate function
    // TODO: bing event listener with the button
    $button.addEventListener('click', function (e) {
      e.preventDefault()
      try {
        ModalManager.prototype.getAction(modalAction).call()
        modal.close()
      } catch (err) {
        console.error(err)
      }
    })
  }
}

ModalManager.prototype.fetchModalContent = function ($form, modal) {
  var formAction = $form.dataset.modalFormAction

  // TODO: bing event listener with the form
  $form.addEventListener('submit', function (e) {
    // preventDefault action and trigger custom function (potentially AJAX call)
    e.preventDefault()

    // AJAX call to formAction
    console.log('form submitted to', formAction)

    const formData = new window.FormData($form)
    window.fetch(formAction, { method: 'POST', body: formData })
      .then(function (response) {
        if (response.ok) {
          // TODO: update modal content or trigger another function
          ModalManager.prototype.handleModalUpdate(modal)
          modal.close()
        }
        return response.text()
      })
      .catch(function (error) {
        console.error(error)
      })
      // .finally(function () { console.log('finally') })
  })
}

ModalManager.prototype.insertImage = function () {
  // TODO: Return a state and trigger a callback function
  console.log('insertImage')
}

var modalManager = new ModalManager()
modalManager.init()
