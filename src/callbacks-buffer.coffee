###*
 * Copyright (C) 2014-2015 Really Inc. <http://really.io>
 * 
 * Callbacks Buffer
 * 
###
protocol = require './protocol'
ReallyError = require './really-error'
_        = require 'lodash'

class CallbacksBuffer
  constructor: () ->
    @tag = 0
    @_callbacks = {}
  
  handle: (message) ->
    throw new ReallyError("A message with this tag: #{message.tag} doesn't exist") unless message.tag of @_callbacks
    {tag} = message
    
    if protocol.isErrorMessage message
      try
        @_callbacks[tag]['error'].call(null, message)
      catch e
        throw new ReallyError('Error happened when trying to execute your error callback')
      
    else
      try
        @_callbacks[tag]['success'].call(null, message)
      catch e
        throw new ReallyError('Error happened when trying to execute your success callback')

    try
      @_callbacks[tag]['complete'].call(null, message)
    catch e
      throw new ReallyError('Error happened when trying to execute your complete callback')

    delete @_callbacks[tag]

  add: (args = {}) ->
    {kind, success, error, complete} = args
    
    kind ?= 'default'
    success ?= _.noop
    error ?= _.noop
    complete ?= _.noop
    
    tag = newTag.call(this)
    
    @_callbacks[tag] = {kind, success, error, complete}

    return tag

  newTag = -> @tag += 1


module.exports = CallbacksBuffer
