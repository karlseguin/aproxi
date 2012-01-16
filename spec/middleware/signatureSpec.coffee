helper = require('../helper')
FakeContext = helper.FakeContext
signature = helper.middleware('./lib/middleware/signature')
config = 
  signature: 
    tags:
      GET:
        'all': ['user', 'asset', 'type'] 
      DELETE:
        '/': ['id', 'verify']   

        
describe 'signature middleware', ->
  it "moves on if not configured for the resource", ->
    Helper.skipsToNext({resource: 'users', method: 'GET'})

  it "moves on if not configured for the method", ->
    Helper.skipsToNext({resource: 'tags', method: 'POST'})

  it "moves on if not configured for the action", ->
    Helper.skipsToNext({resource: 'tags', method: 'DELETE', action: 'all'})

  it "invalid if the signature doesn't exist", ->
    Helper.invalidSignature(null, {resource: 'tags', method: 'GET', action: 'all'})

  it "invalid if the signature doesn't match", ->
    Helper.invalidSignature('bad', {resource: 'tags', method: 'GET', action: 'all', app: {secret: 'xasd'}})

  it "valid when matches", ->
    context = {resource: 'tags', method: 'GET', action: 'all', app: {secret: '43243'}}
    fake = new FakeContext({query: {id: '123', verify: 'kludge', sig: '32c5c9683a2fb482d6f16dacaf9e65077835d67f'}, _aproxi: {context: context}} ,config)
    signature(fake.request, fake.response, fake.pass)
    fake.assertNext()

  it "null action maps to slash", ->
    context = {resource: 'tags', method: 'DELETE', app: {secret: '213'}}
    fake = new FakeContext({query: {id: '123', verify: 'kludge', sig: '448c9018dd8d6db1a7e5291c54a16d0f7f4775b6'}, _aproxi: {context: context}} ,config)
    signature(fake.request, fake.response, fake.pass)
    fake.assertNext()


  
class Helper
  @skipsToNext: (context) ->
    fake = new FakeContext({_aproxi: {context: context}}, config)
    signature(fake.request, null, fake.pass)
    fake.assertNext()

  @invalidSignature: (sig, context) ->
    query = {}
    query.sig = sig if sig?
    fake = new FakeContext({query: query, _aproxi: {context: context}}, config)
    signature(fake.request, fake.response, fake.pass)
    fake.assertError('invalid signature')