module.exports = (conf) ->
  conf.logger.levels = []
  conf.mongodb.databaseName = 'rp_test'
  conf.server.logFiltering = true
  conf.server.port = '13000'
  conf.session.mongodbStore.databaseName = 'rp_session_test'
