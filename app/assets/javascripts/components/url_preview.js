function UrlPreview ($module) {
  this.$module = $module

  this.urlPreview = this.$module.querySelector('.js-url-preview-url')
  this.basePath = this.$module.querySelector('.js-url-preview-path')
  this.defaultMessage = this.$module.querySelector('.js-url-preview-default-message')
  this.errorMessage = this.$module.querySelector('.js-url-preview-error-message')
  this.input = document.querySelector('[data-url-preview="input"]')
  this.form = document.querySelector('[data-url-preview-path]')
  this.path = this.form.getAttribute('data-url-preview-path')
}

UrlPreview.prototype.init = function () {
  var $module = this.$module
  if (!$module || !this.input || !this.path) {
    return
  }

  this.input.addEventListener('blur', this.handleBlur.bind(this))
}

UrlPreview.prototype.showErrorMessage = function () {
  this.urlPreview.classList.add('app-c-url-preview__url--hidden')
  this.defaultMessage.classList.add('app-c-url-preview__default-message--hidden')
  this.errorMessage.classList.remove('app-c-url-preview__error-message--hidden')
}

UrlPreview.prototype.showNoTitleMessage = function () {
  this.urlPreview.classList.add('app-c-url-preview__url--hidden')
  this.defaultMessage.classList.remove('app-c-url-preview__default-message--hidden')
  this.errorMessage.classList.add('app-c-url-preview__error-message--hidden')
}

UrlPreview.prototype.showPathPreview = function (path) {
  this.urlPreview.classList.remove('app-c-url-preview__url--hidden')
  this.defaultMessage.classList.add('app-c-url-preview__default-message--hidden')
  this.errorMessage.classList.add('app-c-url-preview__error-message--hidden')
  this.basePath.innerHTML = path
}

UrlPreview.prototype.fetchPathPreview = function (path, input) {
  var url = new URL(document.location.origin + path)
  url.searchParams.append('title', input.value)

  var controller = new window.AbortController()
  var options = { credentials: 'include', signal: controller.signal }
  setTimeout(function () { controller.abort() }, 5000)

  return window.fetch(url, options)
    .then(function (response) {
      if (!response.ok) {
        throw Error('Unable to generate response.')
      }

      return response.text()
    })
}

UrlPreview.prototype.handleBlur = function (event) {
  var input = event.target

  if (!input.value) {
    this.showNoTitleMessage()
    return
  }
  UrlPreview.prototype.fetchPathPreview(this.path, this.input)
    .then(this.showPathPreview.bind(this))
    .catch(this.showErrorMessage.bind(this))
}

var $urlPreview = document.querySelector('[data-module="url-preview"]')
if ($urlPreview) {
  new UrlPreview($urlPreview).init()
}
