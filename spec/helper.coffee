module.exports.require = (path) ->
  require('../' + path)
  
module.exports.middleware = (path) ->
  new require('../' + path)()

module.exports.store = ->
  store = require('./../lib/store')
  try
    instance = new store.Store()  
  finally
    clearInterval(instance.appCache.pruneId)
  store.instance = instance

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