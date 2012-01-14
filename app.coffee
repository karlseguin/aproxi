config = require('./lib/config')
store = require('./lib/store')
middleware = require('./lib/middleware')
connect = require('connect')
http = require('http')
 
server = connect()
  .use(connect.query())
  .use(middleware.bodyParser())
  .use(middleware.contextLoader())
  .use(middleware.proxy(config.upstream))


store.initialize config.store, (err) ->
  if err?
    console.log('store initialization error: %s', err)
    process.exit(1)
  else
    server.listen(config.port);
    console.log('Server running on port %d', config.port);