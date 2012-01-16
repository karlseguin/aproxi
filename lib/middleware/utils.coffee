module.exports.error = (response, message, code) ->
  response.writeHead(code || 400, {'Content-Type': 'application/json'});
  response.end(JSON.stringify({error: message}))    

module.exports.Date = ->
  new Date()