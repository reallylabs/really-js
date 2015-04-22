WebSocketServer = require('ws').Server
CONFIG = require './config'
wss = new WebSocketServer(port: CONFIG.REALLY_PORT)

wss.on 'connection', (ws) ->
  ws.on 'message', (message) ->
    msg = JSON.parse message
    if msg.testCmd is 'error'
      msg.error = true
      ws.send JSON.stringify msg
      console.log "Error message Received: #{JSON.stringify msg}"
    else
      ws.send message
      console.log "Success message Received: #{message}"

module.exports = wss
