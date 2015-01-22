_ = require 'lodash'
mongoose = require 'mongoose'
Monky = require 'monky'

require 'apps'  # 全 Model 生成が必要なので呼んでいる
#crypto = require 'lib/crypto'


monky = new Monky mongoose
valueSets = {}


#
# User
#
valueSets.user =
  email: 'test-#n@example.com'
  #password: -> crypto.generateHashedPassword valueSets.user.rawPassword, @salt
  rawPassword: 'test1234'
monky.factory 'User', _.omit(valueSets.user, 'rawPassword')


module.exports =
  monky: monky
  valueSets: valueSets
