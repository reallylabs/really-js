# Dependencies

_           = require 'lodash'
Q           = require 'q'
protocol    = require './protocol'
ReallyError = require './really-error'
Emitter     = require 'component-emitter'

class ReallyObject
  constructor: (@channel) -> Emitter this

  get: (r, options) ->
    throw new ReallyError('Can not be initialized without resource') unless _.isString r
    deferred = new Q.defer()
    {fields, onSuccess, onError, onComplete} = options

    try
      message = protocol.getMessage(r, fields)
    catch e
      setTimeout( ->
        deferred.reject e
      , 0)
      return deferred.promise

    @channel.send message, {success: onSuccess, error: onError, complete: onComplete}

  update: (r, rev, options) ->
    throw new ReallyError('Can not be initialized without resource') unless _.isString r
    deferred = new Q.defer()

    unless options
      deferred.reject new ReallyError('Can\'t be called without passing arguments')
      return deferred.promise

    {ops, onSuccess, onError, onComplete} = options

    try
      message = protocol.updateMessage(r, rev, ops)
    catch e
      setTimeout( ->
        deferred.reject e
      , 0)
      return deferred.promise

    @channel.send message, {success: onSuccess, error: onError, complete: onComplete}

  delete: (r, options) ->
    throw new ReallyError('Can not be initialized without resource') unless _.isString r
    {onSuccess, onError, onComplete} = options
    message = protocol.deleteMessage(r)
    @channel.send message, {success: onSuccess, error: onError, complete: onComplete}

  onUpdate: (r, callback) -> @on "#{r}:updated", (data) -> callback data

  onDelete: (r, callback) -> @on "#{r}:deleted", (data) -> callback data

module.exports = ReallyObject
