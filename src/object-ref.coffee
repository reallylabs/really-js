protocol = require './protocol'
ReallyError = require './really-error'
Q = require 'q'

class ObjectRef
  constructor: (@res) ->
    throw new ReallyError('Can not be initialized without resource') unless res
    @rev = 0
    # Listen on event name that matches res of ObjectRef and fire event on
    # this objectref
    Really.on @res, (data) ->
      @emit data.evt, data

  get: (options) ->
    deferred = new Q.defer()
    {fields, onSuccess, onError, onComplete} = options
    try
      message = protocol.getMessage(@res, fields)
    catch e
      setTimeout( ->
        deferred.reject e
      , 0)
      return deferred.promise

    @channel.send message, {success: onSuccess, error: onError, complete: onComplete}

  update: (options) ->
    deferred = new Q.defer()
    unless options
      deferred.reject new ReallyError('Can\'t be called without passing arguments')
      return deferred.promise

    {ops, onSuccess, onError, onComplete} = options

    try
      message = protocol.updateMessage(@res, @rev, ops)
    catch e
      setTimeout( ->
        deferred.reject e
      , 0)
      return deferred.promise

    @channel.send message, {success: onSuccess, error: onError, complete: onComplete}

  delete: (options) ->
    {onSuccess, onError, onComplete} = options
    message = protocol.deleteMessage(@res)
    @channel.send message, {success: onSuccess, error: onError, complete: onComplete}

module.exports = ObjectRef
