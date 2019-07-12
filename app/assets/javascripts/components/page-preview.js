window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function PagePreview () { }

  PagePreview.prototype.start = function ($module) {
    this.$module = $module[0]

    this.mobileIframe = this.$module.querySelector('.app-c-preview__mobile-iframe')
    this.desktopIframe = this.$module.querySelector('.app-c-preview__desktop-iframe')

    this.mobileIframe.onload = function () {
      this.sendMessage(this.mobileIframe, {'hideCookieBanner': 'true'})
    }.bind(this)

    this.desktopIframe.onload = function () {
      this.sendMessage(this.desktopIframe, {'hideCookieBanner': 'true'})
    }.bind(this)
  }

  PagePreview.prototype.sendMessage = function (iframe, dataObject) {
    if (iframe && iframe.contentWindow) {
      var data = JSON.stringify(dataObject)
      iframe.contentWindow.postMessage(data, window.location.origin)
    }
  }

  Modules.PagePreview = PagePreview
})(window.GOVUK.Modules)
