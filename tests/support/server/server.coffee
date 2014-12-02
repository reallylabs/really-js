WebSocketServer = require('ws').Server
CONFIG = require './config'
wss = new WebSocketServer(port: CONFIG.REALLY_PORT)

wss.on 'connection', (ws) ->
  ws.on 'message', (message) ->
    console.log 'received: %s', message
    ws.send message
    # simulate timeout
    # if JSON.parse(message).tag < 7
    #   ws.send message

module.exports = wss
