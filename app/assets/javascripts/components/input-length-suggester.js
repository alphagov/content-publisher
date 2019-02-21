window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function InputLengthSuggester () { }

  InputLengthSuggester.prototype.start = function ($module) {
    this.$module = $module[0]
    this.$target = document.getElementById(this.$module.getAttribute('data-for'))
    this.messageTemplate = this.$module.getAttribute('data-message')
    var showFrom = parseInt(this.$module.getAttribute('data-show-from'), 10)
    this.showFrom = showFrom > 0 ? showFrom : 0
    this.pollInterval = null

    if (!this.$target || !this.messageTemplate) {
      return
    }
    this.update()

    // these 3 cover most bases for a consistent experience
    this.$target.addEventListener('keydown', this.update.bind(this))
    this.$target.addEventListener('keyup', this.update.bind(this))
    this.$target.addEventListener('change', this.update.bind(this))

    // set-up polling
    this.$target.addEventListener('focus', this.handleFocus.bind(this))
    this.$target.addEventListener('blur', this.handleBlur.bind(this))
  }

  InputLengthSuggester.prototype.update = function () {
    var count = this.$target.value.length
    this.$module.textContent = this.messageTemplate.replace(/{count}/g, count)
    if (count >= this.showFrom) {
      this.$module.classList.remove('app-c-input-length-suggester__hidden')
    } else {
      this.$module.classList.add('app-c-input-length-suggester__hidden')
    }
  }

  InputLengthSuggester.prototype.handleFocus = function () {
    if (!this.pollInterval) {
      // according to https://github.com/alphagov/govuk-frontend/blob/29c50367474396a090b31b66bc9a2de3046ed816/src/components/character-count/character-count.js#L119-L121
      // screen readers may modify the input value directly via JS so we have to
      // poll to catch those updates
      this.pollInterval = setInterval(this.update.bind(this), 1000)
    }
  }

  InputLengthSuggester.prototype.handleBlur = function () {
    if (this.pollInterval) {
      clearInterval(this.pollInterval)
      this.pollInterval = null
    }
  }

  Modules.InputLengthSuggester = InputLengthSuggester
})(window.GOVUK.Modules)
