function ModalWorkflow ($modal, actionCallback) {
  this.$modal = $modal
  this.actionCallback = actionCallback

  this.$multiSectionViewer = this.$modal
    .querySelector('[data-module="multi-section-viewer"]')

  this.performAction = this.performAction.bind(this)
  this.renderSuccess = this.renderSuccess.bind(this)
  this.renderError = this.renderError.bind(this)
}

ModalWorkflow.prototype.performAction = function (item) {
  this.$modal.focusDialog()
  this.$multiSectionViewer.showStaticSection('loading')
  this.actionCallback(item)
}

ModalWorkflow.prototype.render = function (response) {
  response
    .then(this.renderSuccess)
    .catch(this.renderError)
}

ModalWorkflow.prototype.renderSuccess = function (result) {
  this.$multiSectionViewer.showDynamicSection(result.body)
  this.setModalAriaLabel(this.getSectionHeadingText())
  this.overrideActions(this.performAction)
  this.initComponents()
}

ModalWorkflow.prototype.renderError = function (result) {
  window.Raven.captureException(result)
  console.error(result)
  this.$multiSectionViewer.showStaticSection('error')
  this.setModalAriaLabel(this.getSectionHeadingText())
}

ModalWorkflow.prototype.getSectionHeadingText = function () {
  var sectionHeading = this.$multiSectionViewer.querySelector('h1')
  if (sectionHeading) {
    return sectionHeading.innerText
  }
}

ModalWorkflow.prototype.setModalAriaLabel = function (ariaLabel) {
  if (ariaLabel) {
    this.$modal.querySelector('dialog').setAttribute('aria-label', ariaLabel)
  }
}

ModalWorkflow.prototype.initComponents = function () {
  window.GOVUK.modules.start(this.$modal)
  window.GOVUKFrontend.initAll(this.$modal)
}

ModalWorkflow.prototype.overrideActions = function (actions) {
  var formItems = this.$modal.querySelectorAll('form[data-modal-action]')
  var clickItems = this.$modal.querySelectorAll('a[data-modal-action], button[data-modal-action]')

  clickItems.forEach(function (item) {
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
