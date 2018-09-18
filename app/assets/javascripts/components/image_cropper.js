//= require vendor/cropperjs/dist/cropper.js

var $imageCroppers = document.querySelectorAll('[data-module="image-cropper"]')

/* eslint-disable */
if ($imageCroppers) {
  $imageCroppers.forEach(function ($imageCropper) {
    var $image = $imageCropper.querySelector('.app-c-image-cropper__image')

    var width = $image.clientWidth
    var height = $image.clientHeight
    var naturalWidth  = $image.naturalWidth
    var naturalHeight  = $image.naturalHeight
    var resizeRatio = 1
    var minCropBoxWidth = 960
    var minCropBoxHeight = 640

    if (width < naturalWidth || height < naturalHeight) {
      var resizeRatio = width/naturalWidth
      var minCropBoxWidth = minCropBoxWidth * resizeRatio
      var minCropBoxHeight = minCropBoxHeight * resizeRatio
    }

    if ($image){
      new Cropper($image,{
        viewMode: 2,
        aspectRatio: 3 / 2,
        autoCrop: true,
        autoCropArea: 1,
        guides: false,
        zoomable: false,
        highlight: false,
        minCropBoxWidth: minCropBoxWidth,
        minCropBoxHeight: minCropBoxHeight
      })
    }
  })
}
/* eslint-enable */
