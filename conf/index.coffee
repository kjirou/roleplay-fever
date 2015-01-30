session = require 'express-session'
MongoStore = require('connect-mongo')(session)
mongoose = require 'mongoose'
pathModule = require 'path'
wantit = require 'wantit'


mongodbConf =
  host: 'localhost'
  port: '27017'
  databaseName: 'rp'
  user: ''
  pass: ''
  prepareConnections: ->
    uri = "mongodb://#{mongodbConf.host}:#{mongodbConf.port}/#{mongodbConf.databaseName}"
    mongoose.connect uri, {
      user: mongodbConf.user
      pass: mongodbConf.pass
    }, (e) ->
      throw e if e

sessionMongoDbStoreConf =
  host: mongodbConf.host
  port: mongodbConf.port
  databaseName: 'rp_session'
  user: mongodbConf.user
  pass: mongodbConf.pass
  clearInterval: 3600
  prepareConnection: ->
    new MongoStore {
      host: sessionMongoDbStoreConf.host
      port: sessionMongoDbStoreConf.port
      db: sessionMongoDbStoreConf.databaseName
      username: sessionMongoDbStoreConf.user
      password: sessionMongoDbStoreConf.pass
      clear_interval: sessionMongoDbStoreConf.clearInterval
    }

root = pathModule.resolve process.env.NODE_PATH
appsRoot = pathModule.join root, 'apps'
viewRoot = pathModule.join root, 'views'
appsViewRoot = pathModule.join viewRoot, 'apps'

conf =
  appsRoot: appsRoot
  appsViewRoot: appsViewRoot
  auth:
    hmacSecretKey: 'your_secret_key'
  debug: true
  env: process.env.NODE_ENV
  logger:
    levels: ['log', 'error']
  mongodb: mongodbConf
  root: root
  server:
    # true=ログを全く出力しない、false=全リクエストを出力、
    #   null=デフォルト（静的ファイルは拡張子で除外など）に従う
    logFiltering: null
    # morgan 準拠でログ書式を設定する、デフォルトは env 依存で変わる
    logFormatType: null
    port: '3000'
  session:
    secret: 'your_secret_key'
    mongodbStore: sessionMongoDbStoreConf
  viewRoot: viewRoot


wantit('conf/' + conf.env)?(conf)


module.exports = conf
