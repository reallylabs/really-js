###*
 * Transport
 * ---------
 * This module works as a transport for really.js for managing connection to 
 * really server 
###

class Transport

  constructor: (@url) -> undefined

  connect: () -> undefined

  disconnect: () -> undefined

  send: (message) -> undefined

  isConnected: () -> undefined

  on: (eventName, callback) -> undefined

module.exports = Transport
