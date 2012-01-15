module.exports =
  port: 4000
  upstream: 
    port: 3000
    host: '127.0.0.1'
  store:
    log:
      port: 27017
      host: '127.0.0.1'
      database: 'little_logs'
    app:
      port: 27017
      host: '127.0.0.1'
      database: 'little'
  middleware:
    contextLoader:
      routePattern: /\/v(\d+)\/(\w+)(\/(\w+))?/
      captures: 
        version: 1
        resource: 2
        action: 4
