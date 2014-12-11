_ = require 'lodash'
protocol = require './protocol'
ReallyError = require './really-error'
Q = require 'q'

class CollectionRef
  constructor: (@res) ->
    throw new ReallyError('Can not be initialized without resource') unless res
    @rev = 0
    # Listen on event name that matches res of CollectionRef and fire event on
    # this CollectionRef
    Really.on @res, (data) ->
      @emit data.evt, data

  create: (options) ->
    deferred = new Q.defer()
    {onSuccess, onError, onComplete, body} = options

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
    protocolOpttions = _.omit options, ['onSuccess', 'onError', 'onComplete']

    try
      message = protocol.readMessage(@res, protocolOpttions)
    catch e
      setTimeout( ->
        deferred.reject e
      , 0)
      return deferred.promise

    @channel.send message, {success: onSuccess, error: onError, complete: onComplete}



module.exports = CollectionRef
