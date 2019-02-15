function ModalDialogue ($module) {
  this.$module = $module
  this.$dialogBox = $module.querySelector('.app-c-modal-dialogue__box')
  this.$closeButton = $module.querySelector('.app-c-modal-dialogue__close-button')
  this.$content = $module.querySelector('.app-c-modal-dialogue__content')
  this.$body = document.querySelector('body')
}

ModalDialogue.prototype.init = function () {
  if (!this.$module) {
    return
  }

  this.$module.open = this.handleOpen.bind(this)
  this.$module.close = this.handleClose.bind(this)
  this.$module.setContent = this.handleSetContent.bind(this)
  this.$module.boundKeyDown = this.handleKeyDown.bind(this)

  var $triggerElement = document.querySelector('[data-toggle="modal"][data-target="#' + this.$module.id + '"]')
  if ($triggerElement) {
    $triggerElement.addEventListener('click', this.$module.open)
  }

  if (this.$closeButton) {
    this.$closeButton.addEventListener('click', this.$module.close)
  }
}

ModalDialogue.prototype.handleOpen = function (event) {
  if (event) {
    event.preventDefault()
  }
  this.$body.classList.add('app-o-template__body--modal')
  this.$body.classList.add('app-o-template__body--blur')
  this.$focusedElementBeforeOpen = document.activeElement
  this.$module.style.display = 'block'
  this.$dialogBox.focus()

  document.addEventListener('keydown', this.$module.boundKeyDown, true)
}

ModalDialogue.prototype.handleClose = function (event) {
  if (event) {
    event.preventDefault()
  }
  this.$body.classList.remove('app-o-template__body--modal')
  this.$body.classList.remove('app-o-template__body--blur')
  this.$module.style.display = 'none'
  this.$focusedElementBeforeOpen.focus()

  document.removeEventListener('keydown', this.$module.boundKeyDown, true)
}

ModalDialogue.prototype.handleSetContent = function (content) {
  this.$content.innerHTML = content
}

// while open, prevent tabbing to outside the dialogue
// and listen for ESC key to close the dialogue
ModalDialogue.prototype.handleKeyDown = function (event) {
  var KEY_TAB = 9
  var KEY_ESC = 27

  switch (event.keyCode) {
    case KEY_TAB:
      if (event.shiftKey) {
        if (document.activeElement === this.$dialogBox) {
          event.preventDefault()
          this.$closeButton.focus()
        }
      } else {
        if (document.activeElement === this.$closeButton) {
          event.preventDefault()
          this.$dialogBox.focus()
        }
      }

      break
    case KEY_ESC:
      this.$module.close()
      break
    default:
      break
  }
}

// Initialise modals
var $modalDialogues = document.querySelectorAll('[data-module="modal-dialogue"]')
$modalDialogues.forEach(function ($el) {
  var $modalDialogue = new ModalDialogue($el)
  $modalDialogue.init()
})
