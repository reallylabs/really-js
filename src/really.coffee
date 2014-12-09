Channel = require './transports/webSocket'
# Authenticaiton = require './src/authenticaiton.coffee'
Emitter = require 'component-emitter'
protocol = require './protocol'
ObjectRef = require './object-ref'
ReallyError = require './really-error'
CollectionRef = require './collection-ref'

class Really
  constructor: (domain, options) ->
    if options.heartbeatInterval < 0 or options.heartbeatTimeout < 0
      throw new ReallyError('Heartbeat interval and timeout should be positive values only')
    console.log 'Really Object initialized'
    defaults =
      heartbeatInterval: 5e3 # 5 seconds
      heartbeatTimeout: 5e3 # 5 seconds
    options = _.defaults options, defaults
    @channel = new Channel(domain, 'FakeAccessToken', options)
    @channel.connect()
    @ObjectRef = ObjectRef
    @ObjectRef::channel = @channel
    @CollectionRef = CollectionRef
    @CollectionRef::channel = @channel
    # authenticationPromise = null
    
    # authentication.login().done (data) =>
    #   @channel = new domain, data.accessToken
    #   authenticationPromise = @channel.connect()

    # authenticationPromise.done () =>
    #   @emit 'really:started'
   
  Emitter(Really)
  
  subscribe: (res, rev, options) ->
    {onSuccess, onError, onComplete} = options
    try
      message = protocol.subscribeMessage(res)
    catch e
      setTimeout( ->
        deferred.reject e
      , 0)
      return deferred.promise
    @channel.send message, {success: onSuccess, error: onError}
  
  unsubscribe: (res, options) ->
    {onSuccess, onError, onComplete} = options
    try
      message = protocol.unsubscribeMessage(res)
    catch e
      setTimeout( ->
        deferred.reject e
      , 0)
      return deferred.promise
    
    @channel.send message, {success: onSuccess, error: onError}

module.exports = Really
