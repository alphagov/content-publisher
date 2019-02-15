function AddInlineImage (trigger) {
  this.$trigger = trigger
  this.$modal = document.getElementById("modal")
  this.$modalBody = this.$modal.querySelector('.app-c-modal-dialogue__body')
}

AddInlineImage.prototype.init = function () {
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
          $module.$modalBody.innerHTML = text
          $module.overrideActions()
        })
        .catch(function (result) {
          $module.$modalBody.innerHTML = '<p class="govuk-error-message">' + result + '</p>'
        })
    },
    'insert': function () {
      var editor = this.$trigger.closest('[data-module="markdown-editor"]')
      this.$modal.close()
      editor.selectionReplace(item.dataset.modalData)
    }
  }

  handlers[item.dataset.modalAction].bind(this)()
}

AddInlineImage.prototype.overrideActions = function () {
  var items = this.$modalBody.querySelectorAll('[data-modal-action]')
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
