function MultiSectionViewer ($container) {
  this.$container = $container
  this.$dynamicSection = $container.querySelector('.js-dynamic-section')
}

MultiSectionViewer.prototype.init = function () {
  var actions = document.querySelectorAll('[data-toggle="multi-section-viewer"][data-target="' + this.$container.id + '"]')
  var $module = this

  actions.forEach(function (action) {
    action.addEventListener('click', function (event) {
      event.preventDefault()
      $module.showStaticSection(event.target.dataset.targetSection)
    })
  })
}

MultiSectionViewer.prototype.hideAllSections = function () {
  var sections = this.$container.querySelectorAll('.app-c-multi-section-viewer__section')

  sections.forEach(function (section) {
    section.style.display = 'none'
  })
}

MultiSectionViewer.prototype.showDynamicSection = function (content) {
  this.hideAllSections()
  this.$dynamicSection.innerHTML = content
  this.$dynamicSection.style.display = 'block'
}

MultiSectionViewer.prototype.showStaticSection = function (name) {
  this.hideAllSections()
  var section = this.$container.querySelector('#' + name)
  section.style.display = 'block'
}

var multiSectionViewers = document.querySelectorAll('[data-module="multi-section-viewer"]')

multiSectionViewers.forEach(function (multiSectionViewer) {
  new MultiSectionViewer(multiSectionViewer).init()
})
