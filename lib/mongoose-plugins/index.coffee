_ = require 'lodash'
mongoose = require 'mongoose'
idExtractor = require 'mongoose-id-extractor-plugin'
_s = require 'underscore.string'

{assertPopulated, toObjectIdCondition} = require 'modules/mongoose-utils'


@plugins = {
  idExtractor
}

@plugins.core = (schema, options) ->

  _.extend schema.methods,

    assertPopulated: ->
      (_.partial assertPopulated, @)(arguments...)

  _.extend schema.statics,

    queryOneById: (id) ->
      @findOne({_id: toObjectIdCondition id})

    findOneById: (id, callback) ->
      @queryOneById(id).exec callback

@plugins.createdAt = (schema, options) ->
  schema.add {
    created_at:
      type: Date
  }
  schema.pre 'save', (callback) ->
    if @isNew
      @created_at = new Date
    callback()

@plugins.updatedAt = (schema, options) ->
  schema.add {
    updated_at:
      type: Date
  }
  schema.pre 'save', (callback) ->
    if @isNew and @created_at
      @updated_at = @created_at
    else
      @updated_at = new Date
    callback()


# プラグインを一括定義する
# 1)順番の設定 2)同じプラグインの複数回実行 が要件なので設定は配列である必要がある
@definePlugins = (schema, pluginSettings...) ->
  pluginSettings.forEach (setting) ->
    [pluginName, pluginOptions] = if Array.isArray setting then setting else [setting, undefined]
    exports.plugins[pluginName](schema, pluginOptions ? {})
