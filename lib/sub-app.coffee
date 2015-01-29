express = require 'express'
_ = require 'lodash'
pathModule = require 'path'
_s = require 'underscore.string'

conf = require 'conf'
{bindPathRoot} = require 'lib/core'


@getSubAppRoot = (subAppName) ->
  pathModule.join conf.appsRoot, subAppName

@getSubAppViewRoot = (subAppName) ->
  pathModule.join conf.appsViewRoot, subAppName

@_createSubAppMiddleware = (subAppName) =>
  subAppRoot = @getSubAppRoot subAppName
  subAppViewRoot = @getSubAppViewRoot subAppName

  (req, res, next) ->
    res.subApp = {}

    res.subApp.render = _.bind(bindPathRoot(subAppViewRoot, res.render), res)

    res.subApp.renderForm = (templatePath, locals={}) ->
      res.subApp.render templatePath, _.extend {
        # 値の保持用の フィールド名:値 のセット
        inputs: {}
        # ErrorReporter インスタンス
        error: null
      }, locals

    next()

@create = (subAppName) =>
  subApp = express()

  subApp.set 'sub_app root', @getSubAppRoot(subAppName)
  subApp.set 'sub_app view_root', @getSubAppViewRoot(subAppName)

  subApp.locals =
    _: _
    _s: _s
    basedir: conf.viewRoot
    pretty: true

  subApp.models = {}

  subApp.use @_createSubAppMiddleware subAppName

  subApp
