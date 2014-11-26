###*
 * Protocol 
 * This module is responsible for generating protocol messages
###
_ = require 'lodash'
authenticator = require './authenticator.coffee'
ReallyError = require './really-error.coffee'

VERSION = '0'
module.exports = 
  
  clientVersion: VERSION

  commands:
    'init': 'init'
    'create': 'create'
    'read': 'read'
    'get': 'get'
    'update': 'update'
    'delete': 'delete'
    'heartbeat': 'poke'

  getInitializationMessage: () ->
    'type': 'initialization'
    'data':
      'cmd': @commands.init
      'accessToken': authenticator.getAccessToken()

  createMessage: (res) ->
    type: 'create'
    data:
      cmd: @commands.create
      res: res

  getMessage: (res, fields) ->
    if not (_.isArray fields or not fields)
      throw new ReallyError 'You should pass array or nothing for fields option'
    
    message = 
      type: 'get'
      data:
        cmd: @commands.get
        r: res
    
    if fields
      message.data.cmdOpts = fields : fields
    return message
  
  updateMessage: (res, rev, ops) ->
    if not ops or ops.length is 0
        throw new ReallyError 'You should pass at least one operation'
    
    supportedOperations = ['set', 'addNumber', 'push', 'addToSet', 'insertAt', 'pull', 'removeAt']
    for operation in ops
      if operation.op not in supportedOperations
        throw new ReallyError "\"#{operation.op}\" operation you passed is not supported"
    
    message = 
      type: 'update'
      data:
        cmd: @commands.update
        rev: rev
        r: res
        body: {ops}

    return message
  
  deleteMessage: (res) ->
    type: 'delete'
    data:
      cmd: @commands.delete
      r: res
 
  heartbeatMessage: () ->
    time = Date.now()
    
    type: 'poke'
    data:
      cmd: @commands.heartbeat
      timestamp: time

  isErrorMessage: (message) -> _.has message, 'error'
