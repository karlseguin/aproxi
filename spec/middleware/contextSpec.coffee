helper = require('../helper')
FakeContext = helper.FakeContext
contextLoader = helper.middleware('./lib/middleware/context')
config = 
    contextLoader: 
        routePattern: /\/v(\d+)\/(\w+)(\/(\w+))?/
        captures: {version: 1, resource: 2, action: 4}
        
describe 'context middleware', ->
  it "loads the context with a full route info", ->
    request = {method: 'GET', url: '/v3/users/rename'}
    fake = new FakeContext(request, config)
    contextLoader(fake.request, null, fake.pass)
    fake.assertNext(1)
    expect(fake.request._aproxi.context.version).toEqual('3')
    expect(fake.request._aproxi.context.resource).toEqual('users')
    expect(fake.request._aproxi.context.action).toEqual('rename')
    expect(fake.request._aproxi.context.url).toEqual('/v3/users/rename')
    expect(fake.request._aproxi.context.method).toEqual('GET')

  it "loads actionless context ", ->
    request = {method: 'POST', url: '/v2/scores'}
    fake = new FakeContext(request, config)
    contextLoader(fake.request, null, fake.pass)
    fake.assertNext(1)
    expect(fake.request._aproxi.context.version).toEqual('2')
    expect(fake.request._aproxi.context.resource).toEqual('scores')
    expect(fake.request._aproxi.context.action).toBeUndefined()
    expect(fake.request._aproxi.context.url).toEqual('/v2/scores')
    expect(fake.request._aproxi.context.method).toEqual('POST')