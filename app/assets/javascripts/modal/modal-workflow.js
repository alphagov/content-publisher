/* global $ */

function ModalWorkflow ($modal) {
  this.$modal = $modal
}

ModalWorkflow.prototype.initComponents = function () {
  window.GOVUK.modules.start($(this.$modal))
  window.GOVUKFrontend.initAll(this.$modal)
}

ModalWorkflow.prototype.overrideActions = function (actions) {
  var formItems = this.$modal.querySelectorAll('form[data-modal-action]')
  var linkItems = this.$modal.querySelectorAll('a[data-modal-action]')

  linkItems.forEach(function (item) {
    item.addEventListener('click', function (event) {
      event.preventDefault()
      actions(item)
    })
  })

  formItems.forEach(function (item) {
    item.addEventListener('submit', function (event) {
      event.preventDefault()
      actions(item)
    })
  })
}
