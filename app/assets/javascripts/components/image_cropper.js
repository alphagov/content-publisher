//= require vendor/cropperjs/dist/cropper.js

var $imageCroppers = document.querySelectorAll('[data-module="image-cropper"]')

/* eslint-disable */
if ($imageCroppers) {
  $imageCroppers.forEach(function ($imageCropper) {
    var $image = $imageCropper.querySelector('.app-c-image-cropper__image')
    var width = $image.clientWidth;
    var height = $image.clientHeight;
    console.log(width + 'x' + height)
    if ($image){
      new Cropper($image,{
        viewMode: 2,
        aspectRatio: 3 / 2,
        autoCrop: true,
        autoCropArea: 1,
        guides: false,
        zoomable: false,
        highlight: false,
        minCropBoxWidth: 300,
        minCropBoxHeight: 200
      })
    }
  })
}
/* eslint-enable */
