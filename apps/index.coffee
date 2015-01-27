async = require 'async'
_ = require 'lodash'
wantit = require 'wantit'


#
# Sub Applications
#
subAppNames = [
  'core'
  'user'
]

subApps = {}
for subAppName in subAppNames
  path = "apps/#{subAppName}"
  subApps[subAppName] =
    path: path
    models: wantit "#{path}/models"
    logics: wantit "#{path}/logics"
    routes: wantit "#{path}/routes"


#
# Models
#
models = {}
for unused, subApp of subApps
  _.extend models, subApp.models ? {}


#
# Routing
#
do ({core, user}=subApps) ->
  core.routes.use '/user', user.routes


module.exports =
  routes: subApps.core.routes
  models: models
  subApps: subApps
