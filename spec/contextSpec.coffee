helper = require('./helper')
store = helper.appStore()
Context = helper.require('./lib/context')

describe 'context.fromRequest', ->
  afterEach -> clearInterval(Context.appCache.pruneId)

  it "get's they key from the query for a GET request", ->
    Helper.lodedFromProperKey('GET', '4efe7c23bb2bfa44c0000003')

  it "get's they key from the query for a DELETE request", ->
    Helper.lodedFromProperKey('DELETE', '4efe7c23bb2bfa44c0000003')

  it "get's they key from the query for a POST request", ->
    Helper.lodedFromProperKey('POST', '4efe7c23bb2bfa44c0000004')

  it "get's they key from the query for a PUT request", ->    
    Helper.lodedFromProperKey('PUT', '4efe7c23bb2bfa44c0000004')

  it "callsback with null context on app load error", ->
    spyOn(store, 'findOne').andCallFake (name, query, cb) -> cb({}, null)
    request = {method: 'GET', query:{key: '4efe7c23bb2bfa44c0000004'}}
    Context.fromRequest request, null, (context) ->
      expect(context).toBeNull()
      expect(Context.appCache.get('4efe7c23bb2bfa44c0000004')).toEqual(undefined)

  it "callsback with null context if app can't be loaded", ->
    spyOn(store, 'findOne').andCallFake (name, query, cb) -> cb(null, null)
    request = {method: 'GET', query:{key: '4efe7c23bb2bfa44c0000004'}}
    Context.fromRequest request, null, (context) ->
      expect(context).toBeNull()
      expect(Context.appCache.get('4efe7c23bb2bfa44c0000004')).toEqual(null)
      
  it "callsback with the context", ->
    app = {}
    spyOn(store, 'findOne').andCallFake (name, query, cb) -> cb(null, app)
    request = {method: 'GET', query:{key: '4efe7c23bb2bfa44c0000005'}}
    Context.fromRequest request, {routePattern: /a/, captures: {}}, (context) ->
      expect(context.app).toBe(app)
      expect(context.method).toEqual('GET')
      expect(Context.appCache.get('4efe7c23bb2bfa44c0000005')).toBe(app)

  it "loads the route info", ->
    spyOn(store, 'findOne').andCallFake (name, query, cb) -> cb(null, {})
    request = {method: 'GET', query:{key: '4efe7c23bb2bfa44c0000005'}, url: '/v3/users/rename'}
    config = {routePattern: /\/v(\d+)\/(\w+)(\/(\w+))?/, captures: {version: 1, resource: 2, action: 4}}
    Context.fromRequest request, config, (context) ->
      expect(context.version).toEqual('3')
      expect(context.resource).toEqual('users')
      expect(context.action).toEqual('rename')
      expect(context.url).toEqual('/v3/users/rename')

  it "loads actionless route info", ->
    spyOn(store, 'findOne').andCallFake (name, query, cb) -> cb(null, {})
    request = {method: 'GET', query:{key: '4efe7c23bb2bfa44c0000005'}, url: '/v3/users'}
    config = {routePattern: /\/v(\d+)\/(\w+)(\/(\w+))?/, captures: {version: 1, resource: 2, action: 4}}
    Context.fromRequest request, config, (context) ->
      expect(context.version).toEqual('3')
      expect(context.resource).toEqual('users')
      expect(context.action).toBeUndefined()
      expect(context.url).toEqual('/v3/users')

class Helper
  @lodedFromProperKey: (method, expected) ->
    spyOn(store, 'findOne')
    request = {method: method, query:{key: '4efe7c23bb2bfa44c0000003'}, body:{key: '4efe7c23bb2bfa44c0000004'}}
    Context.fromRequest request, {}, ->
    expect(store.findOne).toHaveBeenCalledWith('apps', jasmine.any(Object), jasmine.any(Function))
    expect(store.findOne.mostRecentCall.args[1]._id.__id).toEqual(expected) #ughh


