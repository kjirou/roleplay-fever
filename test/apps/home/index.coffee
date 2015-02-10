async = require 'async'
http = require 'http'
_ = require 'lodash'
assert = require 'power-assert'

app = require 'app'
Session = require('supertest-session')(app: app)
{User} = require('apps').models
conf = require 'conf'
{monky, valueSets} = require 'helpers/monky'
{purgeUsers} = require 'helpers/test'


describe 'home sub-app', ->

  describe 'authentication', ->

    beforeEach (done) ->
      purgeUsers =>
        monky.create 'User', (e, @user) => done e

    it 'ログイン済みユーザーがアクセスできる', (done) ->
      session = new Session
      async.series [
        (next) =>
          session
            .post '/login'
            .send { email: @user.email, password: valueSets.user.rawPassword }
            .expect 302
            .end (e, res) ->
              assert.strictEqual res.header.location, '/home'
              next e
        (next) =>
          session
            .get '/home'
            .expect 200
            .end next
      ], done

    it '未ログインユーザーがアクセスできない', (done) ->
      (new Session)
        .get '/home'
        .expect 302
        .end done
