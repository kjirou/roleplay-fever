#express = require 'express'
_ = require 'lodash'
morgan = require 'morgan'
pathModule = require 'path'
urlModule = require 'url'

conf = require 'conf'
#{Http404Error} = require 'lib/errors'
#mongooseUtils = require 'modules/mongoose-utils'


@logServer = ->
  formatType = conf.server.logFormatType ?
    if conf.env is 'production' then 'combined' else 'dev'
  morgan formatType,
    skip: (req, res) ->
      switch conf.server.logFiltering
        when true
          return true
        when false
          return false
      urlData = urlModule.parse req.url
      /\.(css|gif|jpeg|jpg|js|png|woff)$/.test urlData.pathname

## パス内の :id から指定モデルのドキュメントを抽出し req.doc へ格納する
## パス以外からも受け取れるようにする必要が出るかも
#@applyObjectId = (model, options={}) ->
#  options = _.extend {
#    # doc が抽出できなかった場合にエラーを返すか
#    errorClass: null
#  }, options
#
#  (req, res, next) ->
#    toNext = ->
#      if not req.doc and options.errorClass
#        next new options.errorClass
#      else
#        next()
#    req.doc = null
#
#    id = mongooseUtils.toObjectIdCondition req.params.id
#    return toNext() unless id
#
#    model.findOne {_id:id}, (e, doc) ->
#      if e
#        next e
#      else
#        req.doc = doc if doc
#        toNext()
#
#@requireObjectId = (model) ->
#  middlewares.applyObjectId model, errorClass:Http404Error
#
#@csrf = ->
#  (req, res, next) ->
#    if req.disableCsrf
#      next()
#    else
#      express.csrf()(req, res, next)
#
#@disableCsrf = ->
#  (req, res, next) ->
#    req.disableCsrf = true
#    next()
