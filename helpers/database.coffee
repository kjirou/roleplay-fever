async = require 'async'
_ = require 'lodash'

apps = require 'apps'
mongooseUtils = require 'modules/mongoose-utils'


# 全 Model のインデックスを再生成する
exports.ensureModelIndexes = (callback) ->
  tasks = _.values(apps.models).map (model) ->
    (done) -> model.ensureIndexes done
  async.parallel tasks, (e) ->
    return callback e if e
    callback()

exports.resetDatabase = (callback) ->
  mongooseUtils.purgeDatabase (e) ->
    return callback e if e
    exports.ensureModelIndexes callback
