_ = require 'lodash'
Transport = require '../transport'
ReallyError = require '../really-error'
WebSocket = require 'ws'
protocol = require '../protocol'
Emitter = require 'component-emitter'
CallbacksBuffer = require '../callbacks-buffer'
PushHandler = require '../push-handler'
Q = require 'q'
# TODO: timeout should be taken as a parameter
# TODO: if connection get closed stop the heartbeat
class WebSocketTransport extends Transport
  constructor: (@domain, @accessToken, @options) ->
    unless domain and accessToken
      throw new ReallyError('Can\'t initialize connection without passing domain and access token')
    
    unless _.isString(domain) and _.isString(accessToken)
      throw new ReallyError('Only <String> values are allowed for domain and access token')
    
    @socket = null
    @callbacksBuffer = new CallbacksBuffer()
    @_messagesBuffer = []
    @pushHandler = PushHandler
    # connection not initialized yet "we haven't send first message yet"
    @initialized =  false
    @url = "#{domain}/v#{protocol.clientVersion}/socket"
  # Mixin Emitter
  Emitter(WebSocketTransport.prototype)

  _bindWebSocketEvents = ->
    @socket.addEventListener 'open', =>
      _sendFirstMessage.call(this)
      @emit 'opened'
    
    @socket.addEventListener 'close', =>
      @emit 'closed'
      @disconnect()
    
    @socket.addEventListener 'error', =>
      @emit 'error'

    @socket.addEventListener 'message', (e) =>
      data = JSON.parse e.data

      if _.has data, 'tag'
        @callbacksBuffer.handle data
      else
        @pushHandler.handle data

      @emit 'message', data

  _startHeartbeat: () ->
    message = protocol.heartbeatMessage()
    
    success = (data) =>
      clearTimeout @heartbeatTimeoutID
      setTimeout(=>
        @_startHeartbeat.call(this)
      , @options.heartbeatInterval)

    @send message, {success}

    @heartbeatTimeoutID =
    setTimeout( =>
      # we've not received heartbeat response from server yet just die
      clearTimeout @heartbeatTimeoutID
      @emit 'heartbeatLag'
      @disconnect()
    
    , @options.heartbeatTimeout + @options.heartbeatInterval)
 
  send: (message, options = {}) ->
    unless @isConnected() or @isConnecting()
      throw new ReallyError('Connection to the server is not established')
    # if connection is not initialized and this isn't the initialization message
    # buffer messages and send them after initialization
    unless @initialized or message.type is 'initialization'
      @_messagesBuffer.push {message, options}
      return
    # connection is initialized send the message
    deferred = Q.defer()
    {type} = message
   
    success = (data) ->
      options.success? data
      deferred.resolve data
   
    error = (reason) ->
      options.error? reason
      deferred.reject reason

    complete = (data) ->
      options.complete? data
   
    message.data.tag = @callbacksBuffer.add {type, success, error, complete}
    @socket.send JSON.stringify message.data
    return deferred.promise
   
  _sendFirstMessage = ->
    success = (data) =>
      @initialized = true
      # send messages in buffer after the connection being initialized
      _.flush.call(this)
      @_startHeartbeat()
      @emit 'initialized', data
    
    error = (data) =>
      @initialized = false
      @emit 'initializationError', data
    msg = protocol.initializationMessage(@accessToken)
   
    @send msg, {success, error}

  connect: () ->
    # singleton websocket
    @socket ?= new WebSocket(@url)
   
    @socket.addEventListener 'error', _.once ->
      console.log "error initializing websocket with URL: #{@url}"
   
    _bindWebSocketEvents.call(this)
    return @socket
  
  _.flush = ->
    setTimeout(=>
      @send(message, options) for {message, options} in @_messagesBuffer
    , 0)

  isConnected: () ->
    return false if not @socket
    @socket.readyState is @socket.OPEN
  
  isConnecting: () ->
    return false if not @socket
    @socket.readyState is @socket.CONNECTING
 
  _destroy =  () -> @off()
 
  disconnect: () ->
    _destroy.call(this)
    @socket?.close()
    @socket = null
    @initialized = false

module.exports = WebSocketTransport
