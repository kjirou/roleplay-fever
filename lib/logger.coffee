_ = require 'lodash'

conf = require 'conf'


createLogger = ->

  logger =
    log: ->
    error: ->

  conf.logger.levels.forEach (level) ->
    if logger[level]
      logger[level] = console[level]

  logger


module.exports = createLogger
