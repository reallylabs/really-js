# Dependencies

_           = require 'lodash'
Q           = require 'q'
protocol    = require './protocol'
ReallyError = require './really-error'
Emitter     = require 'component-emitter'

class ReallyCollection
  constructor: (@channel) -> Emitter this

  create: (r, options = {}) ->
    throw new ReallyError('Can not be initialized without resource') unless _.isString r
    deferred = new Q.defer()
    {onSuccess, onError, onComplete, body} = options

    try
      message = protocol.createMessage(r, body)
    catch e
      setTimeout( ->
        deferred.reject e
      , 0)

      return deferred.promise

    @channel.send message, {success: onSuccess, error: onError, complete: onComplete}

  read: (r, options = {}) ->
    throw new ReallyError('Can not be initialized without resource') unless _.isString r
    deferred = new Q.defer()

    {onSuccess, onError, onComplete} = options
    protocolOpttions = _.omit options, ['onSuccess', 'onError', 'onComplete']

    try
      message = protocol.readMessage(r, protocolOpttions)
    catch e
      setTimeout( ->
        deferred.reject e
      , 0)
      return deferred.promise

    @channel.send message, {success: onSuccess, error: onError, complete: onComplete}

  onCreate: (r, callback) ->
    @on "#{r}:created", (data) -> callback data

module.exports = ReallyCollection
