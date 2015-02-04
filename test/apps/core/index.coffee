http = require 'http'
_ = require 'lodash'
assert = require 'power-assert'
request = require 'supertest'

app = require 'app'
{User} = require('apps').models
conf = require 'conf'
{monky, valueSets} = require 'helpers/monky'


describe 'core sub-app', ->

  describe 'login', ->

    before ->
      @prepareAndFindUser = (callback) ->
        monky.create 'User', (e, user) ->
          return callback e if e
          User.findOneById user._id, (e, user) ->
            return callback e if e
            callback null, user

      @sessionStore = conf.session.mongodbStore.prepareConnection()

      # セッションデータ全行を配列で返す
      @findSessionRows = (callback) =>
        @sessionStore.getCollection (e, coll) ->
          return callback e if e
          coll.find().toArray callback

      # JSON文字列から復元したセッション情報を配列で返す
      @findSessions = (callback) ->
        @findSessionRows (e, sessionRows) ->
          return callback e if e
          sessions = for sessionRow in sessionRows
            JSON.parse sessionRow.session
          callback null, sessions

      @extractLoggedInSessions = (sessions, userId) ->
        (session for session in sessions when userId.toString() is session.passport?.user)

    beforeEach (done) ->
      @sessionStore.clear (e) =>
        return done e if e
        @findSessionRows (e, sessionRows) ->
          return done e if e
          # Ref https://github.com/kjirou/si_of_sis/issues/98
          if sessionRows.length > 0
            console.error '---- In beforeEach ----'
            console.error sessionRows
          User.remove done

    it 'ユーザーがPOSTでログインできる', (done) ->
      @findSessionRows (e, beforeSessionRows) =>
        # Ref https://github.com/kjirou/si_of_sis/issues/98
        if beforeSessionRows.length > 0
          console.error beforeSessionRows
        @prepareAndFindUser (e, user) =>
          return done e if e
          request(app)
            .post '/login'
            .send { email:user.email, password:valueSets.user.rawPassword }
            .expect 200
            .end =>
              @findSessionRows (e, sessionRows) =>
                # Ref https://github.com/kjirou/si_of_sis/issues/98
                if sessionRows.length > 1
                  console.error sessionRows
                # 2 行なのは、稀にテスト開始前にデータがクリアされていないことがあるため
                # とりあえず諦めて 2 行で判定している、https://github.com/kjirou/si_of_sis/issues/98
                assert sessionRows.length >= 1
                @findSessions (e, sessions) =>
                  loggedInSessions = @extractLoggedInSessions sessions, user._id
                  assert loggedInSessions.length is 1
                  done()

    it 'GETリクエストだとログイン出来ない', (done) ->
      @prepareAndFindUser (e, user) =>
        return done e if e
        request(app)
          .get '/login'
          .send { email:user.email, password:valueSets.rawPassword }
          .expect 200
          .end =>
            @sessionStore.length (e, count) =>
              assert count is 1
              @findSessions (e, sessions) =>
                loggedInSessions = @extractLoggedInSessions sessions, user._id
                assert loggedInSessions.length is 0
                done()

    it '誤ったデータだとログインが失敗する', (done) ->
      @prepareAndFindUser (e, user) =>
        return done e if e
        request(app)
          .post '/login'
          .send { email:user.email, password:'invalid_password' }
          .expect 200
          .end =>
            @sessionStore.length (e, count) =>
              assert count is 1
              @findSessions (e, sessions) =>
                loggedInSessions = @extractLoggedInSessions sessions, user._id
                assert loggedInSessions.length is 0
                done()
