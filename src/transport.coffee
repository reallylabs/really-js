###*
 * Transport
 * ---------
 * This module works as a transport for really.js for managing connection to 
 * really server 
###

class Transport

  constructor: (@url) ->

  connect: () ->

  disconnect: () ->

  send: (message) ->

  isConnected: () ->

  on: (eventName, callback) ->

module.exports = Transport
