/* global ModalFetch, fetchMock */

describe('ModalFetch', function () {
  'use strict'

  describe('ModalFetch.getLink', function () {
    var link

    beforeEach(function () {
      link = document.createElement('a')
      link.href = 'https://example.com/'
    })

    it('returns a promise with body text based on link href', function (done) {
      fetchMock.get('https://example.com', 'Response content')
      var promise = ModalFetch.getLink(link)
      promise.then(function (response) {
        expect(response).toEqual({ body: 'Response content' })
        done()
      })
    })

    it('sets headers to set modal context and include credentials', function () {
      fetchMock.get('https://example.com', 200)
      ModalFetch.getLink(link)
      expect(fetchMock.lastOptions()).toEqual(jasmine.objectContaining({
        credentials: 'include',
        headers: { 'Content-Publisher-Rendering-Context': 'modal' }
      }))
    })

    it('allows overwriting the url with the modalActionUrl data attribute ', function (done) {
      link.dataset.modalActionUrl = 'https://example.com/other'
      fetchMock.get('https://example.com/other', 'Other content')
      var promise = ModalFetch.getLink(link)
      promise.then(function (response) {
        expect(response).toEqual({ body: 'Other content' })
        done()
      })
    })

    it('returns a rejected promise on an unsuccessful request', function (done) {
      fetchMock.get('https://example.com', 404)
      var promise = ModalFetch.getLink(link)
      promise.catch(function (error) {
        expect(error).toEqual('Unable to fetch modal content')
        done()
      })
    })

    it('delegates to ModalFetch.debug an unsuccessful request', function (done) {
      fetchMock.get('https://example.com', 404)
      spyOn(window.ModalFetch, 'debug')
      var promise = ModalFetch.getLink(link)
      promise.catch(function () {
        expect(window.ModalFetch.debug).toHaveBeenCalled()
        done()
      })
    })

    it('times out after 15 seconds', function (done) {
      jasmine.clock().withMock(function () {
        fetchMock.get('https://example.com', 200, { delay: 20000 })
        var promise = window.ModalFetch.getLink(link)

        jasmine.clock().tick(15000)

        promise.catch(function (error) {
          expect(error.name).toEqual('AbortError')
          done()
        })
      })
    })
  })

  describe('ModalFetch.postForm', function () {
    var form

    beforeEach(function () {
      form = document.createElement('form')
      form.action = 'https://example.com'
    })

    it('returns a promise with body text of the form response', function (done) {
      fetchMock.post('https://example.com', 'Response content')
      var promise = ModalFetch.postForm(form)
      promise.then(function (response) {
        expect(response).toEqual({
          body: 'Response content',
          unprocessableEntity: false
        })
        done()
      })
    })

    it('returns body text when response is a unprocessable entity', function (done) {
      fetchMock.post(
        'https://example.com',
        { status: 422, body: 'Response content' }
      )
      var promise = ModalFetch.postForm(form)
      promise.then(function (response) {
        expect(response).toEqual({
          body: 'Response content',
          unprocessableEntity: true
        })
        done()
      })
    })

    it('submits the form with modal header, credentials and redirects followed', function () {
      var input = document.createElement('input')
      input.name = 'field'
      input.value = 'value'
      form.appendChild(input)

      fetchMock.post('https://example.com', 200)
      ModalFetch.postForm(form)
      expect(fetchMock.lastOptions()).toEqual(jasmine.objectContaining({
        credentials: 'include',
        redirect: 'follow',
        headers: { 'Content-Publisher-Rendering-Context': 'modal' }
      }))
      var bodyText = new URLSearchParams(fetchMock.lastOptions().body).toString()
      expect(bodyText).toEqual('field=value')
    })

    it('returns a rejected promise on an unsuccessful request', function (done) {
      fetchMock.post('https://example.com', 404)
      var promise = ModalFetch.postForm(form)
      promise.catch(function (error) {
        expect(error).toEqual('Unable to fetch modal content')
        done()
      })
    })

    it('delegates to ModalFetch.debug on an unsuccessful request', function (done) {
      fetchMock.post('https://example.com', 404)
      spyOn(window.ModalFetch, 'debug')
      var promise = ModalFetch.postForm(form)
      promise.catch(function () {
        expect(window.ModalFetch.debug).toHaveBeenCalled()
        done()
      })
    })

    it('times out after 15 seconds for a regular form', function (done) {
      jasmine.clock().withMock(function () {
        fetchMock.post('https://example.com', 200, { delay: 20000 })
        var promise = window.ModalFetch.postForm(form)

        jasmine.clock().tick(15000)

        promise.catch(function (error) {
          expect(error.name).toEqual('AbortError')
          done()
        })
      })
    })

    it('doesn\'t abort on a multipart form submission', function (done) {
      jasmine.clock().withMock(function () {
        form.setAttribute('enctype', 'multipart/form-data')
        fetchMock.post('https://example.com', 'Eventual success', { delay: 20000 })
        var promise = window.ModalFetch.postForm(form)

        jasmine.clock().tick(25000)

        promise.then(function (response) {
          expect(response).toEqual({
            body: 'Eventual success',
            unprocessableEntity: false
          })
          done()
        })
      })
    })
  })

  describe('ModalFetch.debug', function () {
    var meta

    beforeEach(function () {
      meta = document.createElement('meta')
      meta.setAttribute('name', 'app-environment')
      document.head.appendChild(meta)
    })

    afterEach(function () {
      document.head.removeChild(meta)
    })

    it('sends the response text to console.debug when in production', function (done) {
      meta.setAttribute('content', 'production')
      var response = new window.Response('Error message')
      spyOn(console, 'debug')
      ModalFetch.debug(response)
      // This is necessary because the debug call is done on a promise and this
      // method doesn't return a promise of it's own
      setTimeout(function () {
        expect(console.debug).toHaveBeenCalledWith('Error message')
        done()
      }, 0)
    })

    it('doesn\'t send the response text to console.debug outside of production', function (done) {
      meta.setAttribute('content', 'test')
      var response = new window.Response('Error message')
      spyOn(console, 'debug')
      ModalFetch.debug(response)
      setTimeout(function () {
        expect(console.debug).not.toHaveBeenCalled()
        done()
      }, 0)
    })
  })
})
