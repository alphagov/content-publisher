function AddInlineImage (trigger) {
  this.$trigger = trigger
  this.$modal = document.getElementById('modal')
  this.$modalBody = this.$modal.querySelector('.app-c-modal-dialogue__body')
  this.$initialBodyHTML = this.$modalBody.innerHTML
}

AddInlineImage.prototype.init = function () {
  var $module = this

  if (!this.$trigger) {
    return
  }

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

AddInlineImage.prototype.showStaticPage = function (page) {
  this.$modalBody.innerHTML = this.$initialBodyHTML

  var pages = {
    'error': this.$modalBody.querySelector('#modal-error'),
    'loading': this.$modalBody.querySelector('#modal-loading')
  }

  Object.values(pages).forEach(function (page) {
    page.style.display = 'none'
  })

  pages[page].style.display = 'block'
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
          $module.showStaticPage('error')
        })
    },
    'insert': function () {
      var editor = this.$trigger.closest('[data-module="markdown-editor"]')
      this.$modal.close()
      editor.selectionReplace(item.dataset.modalData)
    }
  }

  this.showStaticPage('loading')
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
