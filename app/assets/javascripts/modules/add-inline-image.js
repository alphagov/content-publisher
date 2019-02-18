function AddInlineImage (trigger) {
  this.$trigger = trigger
  this.$modal = document.getElementById('modal')
}

AddInlineImage.prototype.init = function () {
  var $module = this

  if (!this.$trigger || !this.$modal) {
    return
  }

  this.$multiSectionViewer = new MultiSectionViewer(this.$modal.querySelector('[data-module="multi-section-viewer"]'))
  this.$multiSectionViewer.init()

  this.$trigger.addEventListener('click', function (event) {
    event.preventDefault()
    $module.performAction($module.$trigger)
  })
}

AddInlineImage.prototype.fetchModalContent = function (url) {
  var controller = new window.AbortController()
  var headers = { 'X-Requested-With': 'XMLHttpRequest' }
  var options = { credentials: 'include', signal: controller.signal, headers: headers }
  setTimeout(function () { controller.abort() }, 5000)

  return window.fetch(url, options)
    .then(function (response) {
      if (!response.ok) {
        return window.Promise.reject('Unable to render the content.')
      }
      return response.text()
    })
}

AddInlineImage.prototype.performAction = function (item) {
  var handlers = {
    'open': function () {
      this.$modal.open()
      var $module = this

      this.fetchModalContent(item.dataset.modalActionUrl)
        .then(function (text) {
          $module.$multiSectionViewer.showDynamicSection(text)
          $module.overrideActions()
        })
        .catch(function (result) {
          $module.$multiSectionViewer.showStaticSection('error')
        })
    },
    'insert': function () {
      var editor = this.$trigger.closest('[data-module="markdown-editor"]')
      this.$modal.close()
      editor.selectionReplace(item.dataset.modalData)
    }
  }

  this.$multiSectionViewer.showStaticSection('loading')
  handlers[item.dataset.modalAction].bind(this)()
}

AddInlineImage.prototype.overrideActions = function () {
  var items = this.$modal.querySelectorAll('[data-modal-action]')
  var $module = this

  items.forEach(function (item) {
    item.addEventListener('click', function (event) {
      event.preventDefault()
      $module.performAction(item)
    })
  })
}

var element = document.querySelector('[data-module="add-inline-image"]')
new AddInlineImage(element).init()
