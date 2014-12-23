###*
 * ReallyError
 * ------------
 * This module extends the JavaScript Error
###
class ReallyError extends Error
  constructor: (@message = 'Unknown Error') ->
    # captureStackTrace only supported in v8 
    # http://stackoverflow.com/questions/1382107/whats-a-good-way-to-extend-error-in-javascript
    Error.captureStackTrace?(this, ReallyError)
    @name = 'ReallyError'

module.exports = ReallyError
