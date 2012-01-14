helper = require('./helper')
store = helper.store()
Context = helper.require('./lib/context')

describe 'context.fromRequest', ->
  it "get's they key from the query for a GET request", ->
    Helper.lodedFromProperKey('GET', 'query-key')

  it "get's they key from the query for a DELETE request", ->
    Helper.lodedFromProperKey('DELETE', 'query-key')

  it "get's they key from the query for a POST request", ->
    Helper.lodedFromProperKey('POST', 'body-key')

  it "get's they key from the query for a PUT request", ->    
    Helper.lodedFromProperKey('PUT', 'body-key')

  it "callsback with null context if app can't be loaded", ->
    spyOn(store, 'getApp').andCallFake (key, cb) -> cb(null, null)
    request = {method: 'GET', query:{key: 'query-key'}}
    Context.fromRequest request, (context) ->
      expect(context).toBeNull()
      
  it "callsback with the context", ->
    app = {}
    spyOn(store, 'getApp').andCallFake (key, cb) -> cb(null, app)
    request = {method: 'GET', query:{key: 'query-key'}}
    Context.fromRequest request, (context) ->
      expect(context.app).toBe(app)
      expect(context.method).toEqual('GET')
    

class Helper
  @lodedFromProperKey: (method, expected) ->
    spyOn(store, 'getApp')
    request = {method: method, query:{key: 'query-key'}, body:{key: 'body-key'}}
    Context.fromRequest request, ->
    expect(store.getApp).toHaveBeenCalledWith(expected, jasmine.any(Function))