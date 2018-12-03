//= require govuk_publishing_components/dependencies
//= require govuk_publishing_components/all_components

// support ES5
//= require es5-polyfill/dist/polyfill.js

// support ES6 custom elements
//= require @webcomponents/custom-elements/custom-elements.min.js

// support ES6 fetch
//= require abortcontroller-polyfill/dist/abortcontroller-polyfill-only.js
//= require url-polyfill/url-polyfill.js
//= require promise-polyfill/dist/polyfill.js
//= require whatwg-fetch/dist/fetch.umd.js

// support ES6 utilities
//= require mdn-polyfills/NodeList.prototype.forEach

//= require components/autocomplete.js
//= require components/error-alert.js
//= require components/image-cropper.js
//= require components/input-length-suggester.js
//= require components/markdown-editor.js
//= require components/url-preview.js
//= require vendor/@alphagov/miller-columns-element/dist/index.umd.js

/**
 * contextual guidance need to be initialised after the rest of the components
 * as it may need to be applied to a JavaScript enchanced element (i.e. autocomplete)
 **/
//= require components/contextual-guidance.js

/* global Raven */
var $sentryDsn = document.querySelector('meta[name=sentry-dsn]')
var $sentryCurrentEnv = document.querySelector('meta[name=sentry-current-env]')

if ($sentryDsn && $sentryCurrentEnv) {
  Raven.config($sentryDsn.getAttribute('content'), {
    environment: $sentryCurrentEnv.getAttribute('content')
  }).install()
}
