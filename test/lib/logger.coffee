assert = require 'power-assert'

createLogger = require 'lib/logger'


describe 'logger module', ->

  it 'logger instance', ->
    logger = createLogger()
    logger.log 'foo'
    assert typeof logger.log is 'function'
    logger.error 'foo'
    assert typeof logger.error is 'function'
