function ModalEditor ($module) {
  this.$module = $module
  this.$editor = this.$module.closest('[data-module="markdown-editor"]')
}

ModalEditor.prototype.insertBlock = function (data) {
  this.$editor.selectionReplace(data, { surroundWithNewLines: true })
}

ModalEditor.prototype.insertInline = function (data) {
  this.$editor.selectionReplace(data)
}
