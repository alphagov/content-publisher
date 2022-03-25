window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function MultiSectionViewer ($module) {
    this.$module = $module
    this.$dynamicSection = this.$module.querySelector('.js-dynamic-section')
  }

  MultiSectionViewer.prototype.init = function () {
    var actions = document.querySelectorAll(
      '[data-toggle="multi-section-viewer"][data-target="' + this.$module.id + '"]'
    )

    actions.forEach(function (action) {
      action.addEventListener('click', function (event) {
        event.preventDefault()
        this.showStaticSection(event.target.dataset.targetSection)
      }.bind(this))
    }.bind(this))

    this.$module.hideAllSections = this.hideAllSections.bind(this)
    this.$module.showDynamicSection = this.showDynamicSection.bind(this)
    this.$module.showStaticSection = this.showStaticSection.bind(this)
  }

  MultiSectionViewer.prototype.hideAllSections = function () {
    var sections = this.$module.querySelectorAll('.app-c-multi-section-viewer__section')

    sections.forEach(function (section) {
      section.style.display = 'none'
    })
  }

  MultiSectionViewer.prototype.showDynamicSection = function (content) {
    this.hideAllSections()
    this.$dynamicSection.innerHTML = content
    this.$dynamicSection.style.display = 'block'
  }

  MultiSectionViewer.prototype.showStaticSection = function (id) {
    this.hideAllSections()
    var section = this.$module.querySelector('#' + id)
    section.style.display = 'block'
  }

  Modules.MultiSectionViewer = MultiSectionViewer
})(window.GOVUK.Modules)
