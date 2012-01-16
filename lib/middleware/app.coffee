utils = require('./utils')
store = require('./../store').appStore
Cache = require('./../cache')

appCache = new Cache(30)
appLoader =  ->
  appLoader = (request, response, next) ->
    return next() if request._appLoader
    request._appLoader = true

    method = request.method
    key = if method == 'GET' || method == 'DELETE' then request.query['key'] else request.body['key']
    key = store.idFromString(key)

    return invalid(response) unless key?
    
    app = appCache.get(key)
    return invalid(response) if app == null

    if app != undefined
      request._aproxi.context.app = app
      return next()
      
    store.findOne 'apps', {_id: key}, {fields: {_id: false, secret: true}}, (err, app) =>
      return invalid(response) if err?

      appCache.put(key, app)
      return invalid(response) unless app?
      
      request._aproxi.context.app = app
      return next()

invalid = (response) ->
  utils.error(response, 'the key is not valid')

module.exports = appLoader
module.exports.cache = appCache