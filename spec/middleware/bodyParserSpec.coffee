helper = require('../helper')
FakeContext = helper.FakeContext
bodyParser = helper.middleware('./lib/middleware/bodyParser')

describe 'bodyParser', ->

  it 'should run next on GET request', ->
    fake = new FakeContext({method: 'GET'})
    bodyParser(fake.request, null, fake.pass)
    Helper.assertSkip(fake)

  it 'should run next on DELETE request', ->
    fake = new FakeContext({method: 'DELETE'})
    bodyParser(fake.request, null, fake.pass)
    Helper.assertSkip(fake)

  it 'should return error on invalid content type', ->
    fake = new FakeContext({method: 'POST'}).setHeaders({'content-type': 'text/html'})
    bodyParser(fake.request, fake.response, null)
    fake.assertError('invalid content type')

  it 'should return error on missing content length', ->
    fake = new FakeContext({method: 'POST'}).setHeaders({'content-type': 'application/json'})
    bodyParser(fake.request, fake.response, null)
    fake.assertError('invalid content length')

  it 'parses the body', ->
    fake = new FakeContext({method: 'POST'}).setHeaders({'content-type': 'application/json', 'content-length': 15})

    bodyParser(fake.request, fake.response, fake.pass)
    fake.send(buffer = new Buffer([123,34,110,97,109,101,34,58,34,108,101,116,111,34,125]))
    fake.end()

    expect(fake.request.bodyRaw.toString()).toEqual('{"name":"leto"}')
    expect(fake.request.body).toEqual({name:'leto'})
    fake.assertNext(1)

  it 'parses the body from multiple emits', ->
    fake = new FakeContext({method: 'POST'}).setHeaders({'content-type': 'application/json', 'content-length': 15})

    bodyParser(fake.request, fake.response, fake.pass)
    fake.send(new Buffer([123,34,110,97,109,101,34,58,34,108,101,116]))
    fake.send(new Buffer([111,34,125]))
    fake.end()

    expect(fake.request.bodyRaw.toString()).toEqual('{"name":"leto"}')
    expect(fake.request.body).toEqual({name:'leto'})
    fake.assertNext(1)

  it 'returns an error if the body cannot be parsed', ->
    fake = new FakeContext({method: 'POST'}).setHeaders({'content-type': 'application/json', 'content-length': 15})

    bodyParser(fake.request, fake.response, fake.pass)
    fake.send(new Buffer([123,34,110,97,109,101,34,58,34,108,101,116,111,34]))
    fake.end()
    
    fake.assertError('failed to parse json')


class Helper
  @assertSkip: (fake) ->
    expect(fake.request.body).toBeUndefined()
    expect(fake.request.bodyRaw).toBeUndefined()
    expect(fake.request._bodyParser).toEqual(true)
    fake.assertNext(1)