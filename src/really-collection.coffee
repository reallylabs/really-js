_ = require 'lodash'
protocol = require './protocol'
ReallyError = require './really-error'
Q = require 'q'

class ReallyCollection
  constructor: (@channel) -> return this

  create: (res, options = {}) ->
    throw new ReallyError('Can not be initialized without resource') unless res
    deferred = new Q.defer()
    {onSuccess, onError, onComplete, body} = options

    try
      message = protocol.createMessage(res, body)
    catch e
      setTimeout( ->
        deferred.reject e
      , 0)
      
      return deferred.promise

    @channel.send message, {success: onSuccess, error: onError, complete: onComplete}

  read: (res, options = {}) ->
    throw new ReallyError('Can not be initialized without resource') unless res
    deferred = new Q.defer()

    {onSuccess, onError, onComplete} = options
    protocolOpttions = _.omit options, ['onSuccess', 'onError', 'onComplete']

    try
      message = protocol.readMessage(res, protocolOpttions)
    catch e
      setTimeout( ->
        deferred.reject e
      , 0)
      return deferred.promise

    @channel.send message, {success: onSuccess, error: onError, complete: onComplete}

  onCreate: (res, callback) ->
    @on "#{res}:create", (data) ->
      callback data

module.exports = ReallyCollection
