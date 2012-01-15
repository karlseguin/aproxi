module.exports.require = (path) ->
  require('../' + path)
  
module.exports.middleware = (path, options) ->
  new require('../' + path)(options)

module.exports.appStore = ->
  store = require('./../lib/store')
  instance = new store.Store()
  store.appStore = instance

module.exports.logStore = ->
  store = require('./../lib/store')
  instance = new store.Store()
  store.logStore = instance

class FakeRequest extends require("events").EventEmitter
  constructor: (data) ->
    for d of data
      this[d] = data[d]

class FakeContext
  constructor: (request) ->
    @request = new FakeRequest(request || {})
    @response = 
      writeHead: (code, headers) =>
        @responseCode = code
        @responseHeaders = headers
      end: (body) =>
        @responseBody = body

    @nextCount = 0

  setHeaders: (headers) ->
    @request.headers = headers
    this

  send: (data) ->
    @request.emit 'data', data
    
  end: ->
    @request.emit 'end'

  pass: (err) =>
    @nextCount += 1
    expect(err).toBeUndefined()

  assertNext: (count) ->
    expect(@nextCount).toEqual(count || 1)

  assertError: (body, code) ->
    expect(@responseCode).toEqual(code || 400)
    expect(@responseBody).toEqual(JSON.stringify({error: body}))
    expect(@responseHeaders['Content-Type']).toEqual('application/json')

module.exports.FakeContext = FakeContext