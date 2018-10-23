beforeEach(function () {
  jasmine.addMatchers({
    toBeFocused: function () {
      return {
        compare: function (actual, expected) {
          return {
            pass: actual === actual.ownerDocument.activeElement
          }
        }
      }
    }
  })
})
