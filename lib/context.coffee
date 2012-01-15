Cache = require('./cache')
store = require('./store').appStore

class Context
  @appCache: new Cache(30)
  @captures: ['version', 'resource', 'action']

  constructor: (@app, @method, @url) ->

  parseRoute: (config) ->
    match = config.routePattern.exec(@url)
    for capture in Context.captures when config.captures[capture]?
      value = match[config.captures[capture]]
      this[capture] = value if value
  
  @fromRequest: (request, config, callback) ->

    method = request.method
    key = if method == 'GET' || method == 'DELETE' then request.query['key'] else request.body['key']
    key = store.idFromString(key)

    return callback(null) unless key?
    
    app = @appCache.get(key)
    if app != undefined
      return Context.buildAndCallback(app, method, request, config, callback)

    store.findOne 'apps', {_id: key}, (err, app) =>
      return callback(null) if err?

      @appCache.put(key, app)
      return callback(null) unless app?
      
      Context.buildAndCallback(app, method, request, config, callback)

  @buildAndCallback: (app, method, request, config, callback) ->
    context = new Context(app, method, request.url)
    context.parseRoute(config)
    return callback(context)
      
  
module.exports = Context