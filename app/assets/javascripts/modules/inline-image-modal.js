function InlineImageModal ($module) {
  this.$module = $module
  this.$modal = document.getElementById('modal')
}

InlineImageModal.prototype.init = function () {
  if (!this.$module || !this.$modal) {
    return
  }

  this.$multiSectionViewer = this.$modal
    .querySelector('[data-module="multi-section-viewer"]')

  this.$module.addEventListener('click', function (event) {
    event.preventDefault()
    this.performAction(this.$module)
  }.bind(this))
}

InlineImageModal.prototype.fetchModalContent = function (url) {
  var controller = new window.AbortController()
  var headers = { 'Content-Publisher-Rendering-Context': 'modal' }
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

InlineImageModal.prototype.postModalForm = function (formId) {
  var form = document.getElementById(formId)
  var controller = new window.AbortController()
  setTimeout(function () { controller.abort() }, 10000)

  var options = {
    credentials: 'include',
    signal: controller.signal,
    headers: { 'Content-Publisher-Rendering-Context': 'modal' },
    redirect: 'follow',
    method: 'POST',
    body: (new window.FormData(form))
  }

  return window.fetch(form.action, options)
    .then(function (response) {
      if (!response.ok) {
        return window.Promise.reject('Unable to render the content.')
      }

      return response.text()
    })
}

InlineImageModal.prototype.performAction = function (item) {
  var handlers = {
    'open': function () {
      this.$modal.open()

      this.fetchModalContent(item.dataset.modalActionUrl)
        .then(function (text) {
          this.$multiSectionViewer.showDynamicSection(text)
          this.overrideActions()
          this.initComponents()
        }.bind(this))
        .catch(function (result) {
          this.$multiSectionViewer.showStaticSection('error')
        }.bind(this))
    },
    'insert': function () {
      var editor = this.$module.closest('[data-module="markdown-editor"]')
      this.$modal.close()
      editor.selectionReplace(item.dataset.modalData)
    },
    'upload': function () {
      this.postModalForm(item.dataset.modalActionForm)
        .then(function (text) {
          this.$multiSectionViewer.showDynamicSection(text)
          this.overrideActions()
          this.initComponents()
        }.bind(this))
        .catch(function (result) {
          this.$multiSectionViewer.showStaticSection('error')
        }.bind(this))
    }
  }

  this.$modal.focusDialog()
  this.$multiSectionViewer.showStaticSection('loading')
  handlers[item.dataset.modalAction].bind(this)()
}

InlineImageModal.prototype.initComponents = function () {
  // TODO: change ErrorSummary so it just focusses when it's initialised
  var $errorSummary = document.querySelector('[data-module="error-summary"]')

  if (!$errorSummary) {
    return
  }

  $errorSummary.focus()
}

InlineImageModal.prototype.overrideActions = function () {
  var items = this.$modal.querySelectorAll('[data-modal-action]')

  items.forEach(function (item) {
    item.addEventListener('click', function (event) {
      event.preventDefault()
      this.performAction(item)
    }.bind(this))
  }.bind(this))
}

var element = document.querySelector('[data-module="inline-image-modal"]')
new InlineImageModal(element).init()
