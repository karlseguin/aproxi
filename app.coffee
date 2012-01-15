config = require('./lib/config')
store = require('./lib/store')
connect = require('connect')

store.initialize config.store, (err) ->
  if err?
    console.log('store initialization error: %s', err)
    process.exit(1)
  else
    middleware = require('./lib/middleware')
    server = connect()
      .use(connect.query())
      .use(middleware.bodyParser())
      .use(middleware.contextLoader(config.middleware.contextLoader))
      .use(middleware.proxy(config.upstream))
      .listen(config.port)
    console.log('Server running on port %d', config.port);