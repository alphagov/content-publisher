function ModalPages(container) {
  this.$container = container
  this.$initialInnerHTML = container.innerHTML
  this.$pages = container.querySelectorAll('[data-modal-page]')
}

ModalPages.prototype.init = function () {
  var actions = document.querySelectorAll('[data-toggle="modal-pages"][data-target="' + this.$container.id + '"]')
  var $module = this

  actions.forEach(function (action) {
    action.addEventListener('click', function (event) {
      $module.showPage(event.target.dataset.targetPage)
    })
  })
}

ModalPages.prototype.setContent = function (content) {
  this.$container.innerHTML = content
}

ModalPages.prototype.showPage = function (name) {
  this.setContent(this.$initialInnerHTML)
  var page = this.$container.querySelector('[data-modal-page="' + name + '"]')

  if (!page || page.style.display == 'block') {
    return
  }

  page.style.display = 'block'
}

var modalPages = document.querySelectorAll('[data-module="modal-pages"]')

modalPages.forEach(function (modalPages) {
  new ModalPages(modalPages).init()
})
