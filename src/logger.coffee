_ = require 'lodash'
class Logger
  debug: (args...) ->
    args.unshift 'Really::Debug::'
    console?.debug?.apply console, args
    args
  
  info: (args...) ->
    args.unshift 'Really::Info::'
    console?.log?.apply console, args
    args
  
  warn: (args...) ->
    args.unshift 'Really::Warn::'
    console?.warn?.apply console, args
    args

  error: (args...) ->
    prefix = 'Really::Error::'
    
    if _.isObject args[0]
      code = args[0].code
      message = args[0].message
      errorName = args[0].errorName
      prefix = "#{prefix}#{errorName}::#{code}:: #{message}"
      args.shift()

    args.unshift prefix

    console?.error?.apply console, args
    args

module.exports = Logger
