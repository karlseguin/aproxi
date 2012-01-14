helper = require('../helper')
Context = helper.require('./lib/context')
FakeContext = helper.FakeContext
contextLoader = helper.middleware('./lib/middleware/contextLoader')

describe 'contextLoader', ->
  it 'returns an error if the context cannot be loaded', ->
    context = new Context()
    spyOn(Context, 'fromRequest').andCallFake (r, cb) -> cb(null)
    fake = new FakeContext()
    contextLoader(fake.request, fake.response, null)
    fake.assertError('the key is not valid')

  it 'loads the context into the request', ->
    context = new Context()
    fake = new FakeContext()
    spyOn(Context, 'fromRequest').andCallFake (r, cb) -> 
      expect(r).toBe(fake.request)
      cb(context)

    contextLoader(fake.request, fake.response, fake.pass)

    expect(fake.request._context).toBe(context)
    fake.assertNext()