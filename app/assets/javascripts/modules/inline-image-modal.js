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

InlineImageModal.prototype.fetchModalContent = function (item) {
  var controller = new window.AbortController()
  var headers = { 'Content-Publisher-Rendering-Context': 'modal' }
  var options = { credentials: 'include', signal: controller.signal, headers: headers }
  var url = item.href || item.dataset.modalActionUrl
  setTimeout(function () { controller.abort() }, 5000)

  return window.fetch(url, options)
    .then(function (response) {
      if (!response.ok) {
        return window.Promise.reject('Unable to render the content.')
      }

      return response.text()
        .then(function (text) {
          return { body: text }
        })
    })
}

InlineImageModal.prototype.postModalForm = function (form) {
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
        .then(function (text) {
          return { body: text, redirected: response.redirected }
        })
    })
}

InlineImageModal.prototype.renderResponse = function (response) {
  response
    .then(function (result) {
      this.$multiSectionViewer.showDynamicSection(result.body)
      this.overrideActions()
      this.initComponents()
    }.bind(this))
    .catch(function (result) {
      this.$multiSectionViewer.showStaticSection('error')
    }.bind(this))
}

InlineImageModal.prototype.insertSnippet = function (item) {
  var editor = this.$module.closest('[data-module="markdown-editor"]')
  editor.selectionReplace(item.dataset.modalData)
}

InlineImageModal.prototype.performAction = function (item) {
  var handlers = {
    'open': function () {
      this.$modal.open()
      this.renderResponse(this.fetchModalContent(item))
    },
    'insert': function () {
      this.$modal.close()
      this.insertSnippet(item)
    },
    'upload': function () {
      this.renderResponse(this.postModalForm(item))
    },
    'cropBack': function () {
      this.renderResponse(this.fetchModalContent(item))
    },
    'metaBack': function () {
      this.renderResponse(this.fetchModalContent(item))
    },
    'crop': function () {
      this.renderResponse(this.postModalForm(item))
    },
    'delete': function () {
      this.renderResponse(this.postModalForm(item))
    },
    'meta': function () {
      this.renderResponse(this.postModalForm(item))
    },
    'metaInsert': function () {
      this.postModalForm(item)
        .then(function (result) {
          if (result.finished) {
            this.$modal.close()
            this.insertSnippet(item)
          } else {
            this.$multiSectionViewer.showDynamicSection(result.body)
            this.overrideActions()
            this.initComponents()
          }
        }.bind(this))
        .catch(function (result) {
          this.$multiSectionViewer.showStaticSection('error')
        }.bind(this))
    },
    'edit': function () {
      this.renderResponse(this.fetchModalContent(item))
    }
  }

  this.$modal.focusDialog()
  this.$multiSectionViewer.showStaticSection('loading')
  handlers[item.dataset.modalAction].bind(this)()
}

InlineImageModal.prototype.initComponents = function () {
  window.GOVUK.modules.start()

  // TODO: change ErrorSummary so it just focusses when it's initialised
  var $errorSummary = document.querySelector('[data-module="error-summary"]')

  if (!$errorSummary) {
    return
  }

  $errorSummary.focus()
}

InlineImageModal.prototype.overrideActions = function () {
  var formItems = this.$modal.querySelectorAll('form[data-modal-action]')
  var linkItems = this.$modal.querySelectorAll('a[data-modal-action]')

  linkItems.forEach(function (item) {
    item.addEventListener('click', function (event) {
      event.preventDefault()
      this.performAction(item)
    }.bind(this))
  }.bind(this))

  formItems.forEach(function (item) {
    item.addEventListener('submit', function (event) {
      event.preventDefault()
      this.performAction(item)
    }.bind(this))
  }.bind(this))
}

var element = document.querySelector('[data-module="inline-image-modal"]')
new InlineImageModal(element).init()
