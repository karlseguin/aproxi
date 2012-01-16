module.exports.require = (path) ->
  require('../' + path)
  
module.exports.middleware = (path) ->
  new require('../' + path)()

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
  constructor: (request, config) ->
    @request = new FakeRequest(request || {})
    if config?
      @request['_aproxi'] = {} unless @request['_aproxi']?
      @request['_aproxi'].config = config

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

  assertBody: (body) ->
    expect(@responseBody).toEqual(body)

module.exports.FakeContext = FakeContext