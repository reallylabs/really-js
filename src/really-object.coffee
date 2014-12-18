protocol = require './protocol'
ReallyError = require './really-error'
Q = require 'q'

class ReallyObject
  constructor: (@channel) -> return this
  
  get: (res, options) ->
    throw new ReallyError('Can not be initialized without resource') unless res
    deferred = new Q.defer()
    {fields, onSuccess, onError, onComplete} = options
    
    try
      message = protocol.getMessage(res, fields)
    catch e
      setTimeout( ->
        deferred.reject e
      , 0)
      return deferred.promise

    @channel.send message, {success: onSuccess, error: onError, complete: onComplete}

  update: (res, rev, options) ->
    throw new ReallyError('Can not be initialized without resource') unless res
    deferred = new Q.defer()
    
    unless options
      deferred.reject new ReallyError('Can\'t be called without passing arguments')
      return deferred.promise

    {ops, onSuccess, onError, onComplete} = options

    try
      message = protocol.updateMessage(res, ops)
    catch e
      setTimeout( ->
        deferred.reject e
      , 0)
      return deferred.promise

    @channel.send message, {success: onSuccess, error: onError, complete: onComplete}

  delete: (res, options) ->
    throw new ReallyError('Can not be initialized without resource') unless res
    {onSuccess, onError, onComplete} = options
    message = protocol.deleteMessage(res)
    @channel.send message, {success: onSuccess, error: onError, complete: onComplete}

  onUpdate: (res, callback) ->
    @on "#{res}:update", (data) -> callback data

  onDelete: (res, callback) ->
    @on "#{res}:delete", (data) -> callback data

module.exports = ReallyObject
