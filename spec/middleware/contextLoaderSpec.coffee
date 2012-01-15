helper = require('../helper')
Context = helper.require('./lib/context')
FakeContext = helper.FakeContext
config = {}
contextLoader = helper.middleware('./lib/middleware/contextLoader', config)

describe 'contextLoader', ->
  afterEach -> clearInterval(Context.appCache.pruneId)
  
  it 'returns an error if the context cannot be loaded', ->
    spyOn(Context, 'fromRequest').andCallFake (r, c, cb) -> cb(null)
    fake = new FakeContext()
    contextLoader(fake.request, fake.response, null)
    fake.assertError('the key is not valid')

  it 'loads the context into the request', ->
    context = new Context()
    fake = new FakeContext()
    spyOn(Context, 'fromRequest').andCallFake (r, c, cb) -> 
      expect(r).toBe(fake.request)
      expect(c).toBe(config)
      cb(context)

    contextLoader(fake.request, fake.response, fake.pass)

    expect(fake.request._context).toBe(context)
    fake.assertNext()