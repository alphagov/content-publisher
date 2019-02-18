function ModalPages(container) {
  this.$container = container
  this.$dynamicPage = container.querySelector('.js-dynamic-page')
}

ModalPages.prototype.init = function () {
  var actions = document.querySelectorAll('[data-toggle="modal-pages"][data-target="' + this.$container.id + '"]')
  var $module = this

  actions.forEach(function (action) {
    action.addEventListener('click', function (event) {
      $module.showStaticPage(event.target.dataset.targetPage)
    })
  })
}

ModalPages.prototype.hideAllPages = function () {
  var pages = this.$container.querySelectorAll('.app-c-modal-pages__page')

  pages.forEach(function (page) {
    page.style.display = 'none'
  })
}

ModalPages.prototype.showDynamicPage = function (content) {
  this.hideAllPages()
  this.$dynamicPage.innerHTML = content
  this.$dynamicPage.style.display = 'block'
}

ModalPages.prototype.showStaticPage = function (name) {
  this.hideAllPages()
  var page = this.$container.querySelector('[data-modal-page="' + name + '"]')
  page.style.display = 'block'
}

var modalPages = document.querySelectorAll('[data-module="modal-pages"]')

modalPages.forEach(function (modalPages) {
  new ModalPages(modalPages).init()
})
