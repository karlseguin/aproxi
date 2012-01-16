helper = require('../helper')
store = helper.logStore()
FakeContext = helper.FakeContext
logger = helper.middleware('./lib/middleware/logger')
utils = helper.require('./lib/middleware/utils')

describe 'logger middleware', ->
  it "logs the request details",  ->
    startDate = true
    spyOn(store, 'insert')
    spyOn(utils, 'Date').andCallFake ->
      if startDate
        startDate = false
        return new Date(3394)
      return new Date(3398)

    fake = new FakeContext({_aproxi: {context: {method: 'm1', version: 'v3', resource: 'spice', action: 'harvest', app: {_id: 'the-id'}} }})
    logger(fake.request, fake.response, fake.pass)
    fake.response.statusCode = 555
    fake.response.end()

    expected = {app: 'the-id', method: 'm1', version: 'v3', resource: 'spice', action: 'harvest', time: 4, status: 555}
    expect(store.insert).toHaveBeenCalledWith('proxy_logs', expected);

  it "logs a undefined values", ->
    spyOn(store, 'insert')
    fake = new FakeContext({_aproxi: {context: {}}})
    logger(fake.request, fake.response, fake.pass)
    fake.response.end()
    expected = {app: undefined, method: undefined, version: undefined, resource: undefined, action: undefined, time: 0, status: undefined}
    expect(store.insert).toHaveBeenCalledWith('proxy_logs', expected);

  #weird test, but important that this happens
  it "executes the original end", ->  
    spyOn(store, 'insert')
    fake = new FakeContext({_aproxi: {context: {}}})
    logger(fake.request, fake.response, fake.pass)
    fake.response.end('test')
    fake.assertBody('test')
