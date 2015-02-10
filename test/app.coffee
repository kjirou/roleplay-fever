http = require 'http'
_ = require 'lodash'
assert = require 'power-assert'
request = require 'supertest'

app = require 'app'
{User} = require('apps').models
conf = require 'conf'
{monky, valueSets} = require 'helpers/monky'


describe 'app module', ->

  describe 'server', ->

    it 'Webアプリケーションサーバを起動できる', (done) ->
      # @TODO listen でエラーを出す方法が不明でエラー時の動作確認してない
      server = http.createServer(app).listen conf.server.port, (e) ->
        return done e if e
        server.close (e) ->
          return done e if e
          done()

    it '静的ファイルへリクエストできる', (done) ->
      request(app).get('/robots.txt').expect(200).end done
