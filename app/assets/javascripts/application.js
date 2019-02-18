//= require govuk_publishing_components/dependencies
//= require govuk_publishing_components/all_components

// support ES5
//= require es5-polyfill/dist/polyfill.js

// support ES6 (promises, functions, etc. - see docs)
//= require core-js-bundle/index.js

// support ES6 custom elements
//= require @webcomponents/custom-elements/custom-elements.min.js

// support ES6 fetch and related utilities
//= require abortcontroller-polyfill/dist/abortcontroller-polyfill-only.js
//= require url-polyfill/url-polyfill.js
//= require whatwg-fetch/dist/fetch.umd.js

//= require components/autocomplete.js
//= require components/image-cropper.js
//= require components/input-length-suggester.js
//= require components/markdown-editor.js
//= require components/modal-dialogue.js
//= require components/multi-section-viewer.js
//= require components/url-preview.js
//= require vendor/@alphagov/miller-columns-element/dist/index.umd.js

//= require modules/gtm-form-listener.js
//= require modules/gtm-track-copy.js
//= require modules/inline-image-modal.js
//= require modules/warn-before-unload.js

// load after other components (esp. autocomplete)
//= require components/contextual-guidance.js

// raven (for Sentry)
//= require raven-js/dist/raven.js
var $sentryDsn = document.querySelector('meta[name=sentry-dsn]')
var $sentryCurrentEnv = document.querySelector('meta[name=sentry-current-env]')

if ($sentryDsn && $sentryCurrentEnv) {
  window.Raven.config($sentryDsn.getAttribute('content'), {
    environment: $sentryCurrentEnv.getAttribute('content')
  }).install()
}
