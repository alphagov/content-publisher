window.buildModalDialogue = function buildModalDialogue () {
  window.removeModalDialogue()
  var modal = document.createElement('div')
  modal.className = 'gem-c-modal-dialogue gem-c-modal-dialogue__box--wide'
  modal.id = 'modal'
  modal.innerHTML =
    '<dialog class="gem-c-modal-dialogue__box" aria-modal="true" role="dialogue" aria-labelledby="my-modal-title">' +
      '<div class="gem-c-modal-dialogue__content">' +
        '<div class="app-c-multi-section-viewer" data-module="multi-section-viewer">' +
          '<section class="app-c-multi-section-viewer__section js-dynamic-section"></section>' +
          '<section class="app-c-multi-section-viewer__section" id="loading"></section>' +
          '<section class="app-c-multi-section-viewer__section" id="error"><h1>Something has gone wrong</h1></section>' +
        '</div>' +
      '</div>' +
      '<button class="gem-c-modal-dialogue__close-button" aria-label="Close modal dialogue">&times;</button>' +
    '</dialog>'

  document.body.appendChild(modal)
  new window.GOVUK.Modules.ModalDialogue().start($(modal))

  var multiSectionViewer = modal.querySelector('[data-module="multi-section-viewer"]')
  new window.GOVUK.Modules.MultiSectionViewer().start($(multiSectionViewer))

  return modal
}

window.removeModalDialogue = function removeModalDialogue () {
  var modal = document.getElementById('modal')
  if (modal) {
    modal.close()
    modal.parentNode.removeChild(modal)
  }
}
