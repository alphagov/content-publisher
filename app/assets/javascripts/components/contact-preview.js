window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function ContactPreview () { }

  ContactPreview.prototype.start = function ($module) {
    this.$module = $module[0]

    this.errorMessage = this.$module.querySelector('.js-contact-preview-error-message')
    this.loadingSpinner = this.$module.querySelector('.js-contact-preview-loading-spinner')
    this.contactPreview = this.$module.querySelector('.js-contact-preview-html')
    this.selectId = this.$module.dataset.for
    this.contactSnippetTemplate = this.$module.dataset.contactSnippetTemplate
    this.path = this.$module.dataset.govspeakPath
    this.$select = document.querySelector('#' + this.selectId)
    if (!this.$select || !this.path || !this.contactSnippetTemplate) {
      return
    }
    this.$select.addEventListener('change', this.handleChange.bind(this))
  }

  ContactPreview.prototype.getContactSnippet = function () {
    if (this.$select.value) {
      return this.contactSnippetTemplate.replace('#', this.$select.value)
    }
  }

  ContactPreview.prototype.showErrorMessage = function () {
    this.$module.classList.add('app-c-contact-preview--hidden')
    this.contactPreview.classList.add('app-c-contact-preview__html--hidden')
    this.loadingSpinner.classList.add('app-c-contact-preview__loading-spinner--hidden')
    this.errorMessage.classList.remove('app-c-contact-preview__error-message--hidden')
  }

  ContactPreview.prototype.hideContactPreview = function () {
    this.$module.classList.add('app-c-contact-preview--hidden')
    this.contactPreview.classList.add('app-c-contact-preview__html--hidden')
    this.loadingSpinner.classList.add('app-c-contact-preview__loading-spinner--hidden')
    this.errorMessage.classList.add('app-c-contact-preview__error-message--hidden')
  }

  ContactPreview.prototype.showContactPreview = function (html) {
    this.$module.classList.remove('app-c-contact-preview--hidden')
    this.contactPreview.classList.remove('app-c-contact-preview__html--hidden')
    this.errorMessage.classList.add('app-c-contact-preview__error-message--hidden')
    this.loadingSpinner.classList.add('app-c-contact-preview__loading-spinner--hidden')
    this.contactPreview.innerHTML = html
  }

  ContactPreview.prototype.showLoadingSpinner = function (html) {
    this.$module.classList.remove('app-c-contact-preview--hidden')
    this.contactPreview.classList.add('app-c-contact-preview__html--hidden')
    this.errorMessage.classList.add('app-c-contact-preview__error-message--hidden')
    this.loadingSpinner.classList.remove('app-c-contact-preview__loading-spinner--hidden')
  }

  ContactPreview.prototype.fetchContactPreview = function (contactId) {
    var url = new URL(document.location.origin + this.path)

    var formData = new window.FormData()
    var contactSnippet = this.getContactSnippet()
    formData.append('govspeak', contactSnippet)

    var controller = new window.AbortController()
    var options = { credentials: 'include', signal: controller.signal, method: 'POST', body: formData }
    setTimeout(function () { controller.abort() }, 15000)

    this.showLoadingSpinner()

    return window.fetch(url, options)
      .then(function (response) {
        if (!response.ok) {
          throw Error('Unable to generate response.')
        }

        return response.text()
      })
  }

  ContactPreview.prototype.handleChange = function (event) {
    var select = event.target

    if (!select.value) {
      this.hideContactPreview()
      return
    }

    this.fetchContactPreview(select.value)
      .then(this.showContactPreview.bind(this))
      .catch(this.showErrorMessage.bind(this))
  }

  Modules.ContactPreview = ContactPreview
})(window.GOVUK.Modules)
