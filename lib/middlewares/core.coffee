#express = require 'express'
httpErrors = require 'http-errors'
_ = require 'lodash'
morgan = require 'morgan'
pathModule = require 'path'
urlModule = require 'url'

conf = require 'conf'
{toObjectIdCondition} = require 'modules/mongoose-utils'


# route を通る場合の共通テンプレート変数
@routeLocals = ->
  (req, res, next) ->
    _.extend res.locals,
      req: req
    next()

# Web サーバの出力を行う
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

# パス内の :id から指定モデルのドキュメントを抽出し req.doc へ格納する
# パス以外からも受け取れるようにする必要が出るかも
@applyObjectId = (model, options={}) ->
  options = _.extend {
    # doc が抽出できなかった場合にエラーを返すルーチン
    # null=返さない, func=戻り値がエラーになる
    errorCreator: null
  }, options

  (req, res, next) ->
    toNext = ->
      if not req.doc and options.errorCreator
        next options.errorCreator()
      else
        next()
    req.doc = null

    id = toObjectIdCondition req.params.id
    return toNext() unless id

    model.findOne {_id:id}, (e, doc) ->
      if e
        next e
      else
        req.doc = doc if doc
        toNext()

@requireObjectId = (model) =>
  @applyObjectId model,
    errorCreator: -> httpErrors 404

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
