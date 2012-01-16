helper = require('../helper')
store = helper.appStore()
FakeContext = helper.FakeContext
appLoader = helper.middleware('./lib/middleware/app')

describe 'app middleware', ->
  beforeEach -> @cache = helper.require('./lib/middleware/app').cache
  afterEach -> clearInterval(@cache.pruneId)

  it "get's they key from the query for a GET request", ->
    Helper.lodedFromProperKey('GET', '4efe7c23bb2bfa44c0000003')

  it "get's they key from the query for a DELETE request", ->
    Helper.lodedFromProperKey('DELETE', '4efe7c23bb2bfa44c0000003')

  it "get's they key from the query for a POST request", ->
    Helper.lodedFromProperKey('POST', '4efe7c23bb2bfa44c0000004')

  it "get's they key from the query for a PUT request", ->    
    Helper.lodedFromProperKey('PUT', '4efe7c23bb2bfa44c0000004')

  it "returns error on load error", ->
    spyOn(store, 'findOne').andCallFake (name, query, options, cb) -> cb({}, null)
    request = {method: 'GET', query:{key: '4efe7c23bb2bfa44c0000004'}}
    fake = new FakeContext(request)
    appLoader(fake.request, fake.response, -> )
    fake.assertError('the key is not valid')
    expect(@cache.get('4efe7c23bb2bfa44c0000004')).toEqual(undefined)

  it "returns error if the app isn't found", ->
    spyOn(store, 'findOne').andCallFake (name, query, options, cb) -> cb(null, null)
    request = {method: 'GET', query:{key: '4efe7c23bb2bfa44c0000004'}}
    fake = new FakeContext(request)
    appLoader(fake.request, fake.response, -> )
    fake.assertError('the key is not valid')
    expect(@cache.get('4efe7c23bb2bfa44c0000004')).toEqual(null)
      
  it "callsback with the context", ->
    app = {}
    spyOn(store, 'findOne').andCallFake (name, query, options, cb) -> cb(null, app)
    request = {method: 'GET', query:{key: '4efe7c23bb2bfa44c0000005'}, _aproxi: {context: {}}}
    fake = new FakeContext(request)
    appLoader(fake.request, fake.response, fake.pass)
    fake.assertNext()
    expect(@cache.get('4efe7c23bb2bfa44c0000005')).toBe(app)
    expect(request._aproxi.context.app).toBe(app)
    
class Helper
  @lodedFromProperKey: (method, expected) ->
    spyOn(store, 'findOne')
    request = {method: method, query:{key: '4efe7c23bb2bfa44c0000003'}, body:{key: '4efe7c23bb2bfa44c0000004'}}
    fake = new FakeContext(request)
    appLoader(fake.request, fake.response, fake.pass)
    expect(store.findOne).toHaveBeenCalledWith('apps', jasmine.any(Object), jasmine.any(Object), jasmine.any(Function))
    expect(store.findOne.mostRecentCall.args[1]._id.__id).toEqual(expected) #ughh
    expect(store.findOne.mostRecentCall.args[2]).toEqual({fields: {secret: true}})