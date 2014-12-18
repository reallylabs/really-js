###*
 * ReallyError
 * ------------
 * This module extends the JavaScript Error
###
class ReallyError extends Error
  constructor: (@message = 'Unknown Error') ->
    Error.captureStackTrace(this, ReallyError)
    @name = 'ReallyError'

module.exports = ReallyError
