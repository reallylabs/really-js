###*
 * ReallyError
 * ------------
 * This module extends the JavaScript Error
###
class ReallyError extends Error
  constructor: (@message='Unknown Error') ->
    @name = 'ReallyError'

module.exports = ReallyError
