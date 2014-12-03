protocol = require './protocol.coffee'
ReallyError = require './really-error.coffee'
Q = require 'q'

class CollectionRef
  constructor: (@res) ->
    @rev = 0
    # Listen on event name that matches res of CollectionRef and fire event on
    # this CollectionRef
    Really.on @res, (data) ->
      @emit data.evt, data

  create: (options) ->
    deferred = new Q.defer()
    body = options?.body

    try
      message = protocol.createMessage(@res, body)
    catch e
      setTimeout( ->
        deferred.reject e
      , 0)
      return deferred.promise

    @channel.send message, {success: onSuccess, error: onError, complete: onComplete}

  read: (options) ->
    deferred = new Q.defer()

    {onSuccess, onError, onComplete} = options

    try
      message = protocol.readMessage(@res, options)
    catch e
      setTimeout( ->
        deferred.reject e
      , 0)
      return deferred.promise

    @channel.send message, {success: onSuccess, error: onError}



module.exports = CollectionRef
