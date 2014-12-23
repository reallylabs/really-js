###*
 * really
 * name space for application the parent for object & collection functions
###

Transport = require './transports/webSocket'
ReallyObject = require './really-object'
ReallyCollection = require './really-collection'
ReallyError = require './really-error'
_ = require 'lodash'
store = {}

class Really
  constructor: (domain, accessToken, options) ->
    unless domain and accessToken
      throw new ReallyError('Can\'t initialize Really without passing domain and access token')

    unless _.isString(domain) and _.isString(accessToken)
      throw new ReallyError('Only <String> values are allowed for domain and access token')

    if store[domain]
      @object = store[domain]['object']
      @collection = store[domain]['collection']
    else
      transport = new Transport(domain, accessToken, options)
      transport.connect()
      store[domain] = {}
      @object = store[domain]['object'] = new ReallyObject(transport)
      @collection = store[domain]['collection'] = new ReallyCollection(transport)

    return this

module.exports = Really
  
