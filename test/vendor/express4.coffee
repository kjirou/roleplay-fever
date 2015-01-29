async = require 'async'
express = require 'express'
assert = require 'power-assert'
request = require 'supertest'

app = require 'app'


describe 'express-4.x vendor', ->

  describe 'app', ->

    it '親子関係ではない複数app間でsetした値が共有されていない', ->
      fooApp = express()
      barApp = express()
      fooApp.set 'view engine', 'ejs'
      fooApp.set 'test_value', 1
      assert.strictEqual fooApp.get('view engine'), 'ejs'
      assert.strictEqual fooApp.get('test_value'), 1
      assert.strictEqual fooApp.get('undef_value'), undefined
      assert.strictEqual barApp.get('view engine'), undefined
      assert.strictEqual barApp.get('test_value'), undefined

    it '親子関係である複数app間でsetした値が共有されている', ->
      parentApp = express()
      childApp = express()
      parentApp.set 'view engine', 'ejs'
      parentApp.set 'test_value', 1
      parentApp.use '/child', childApp
      assert.strictEqual childApp.get('view engine'), 'ejs'
      assert.strictEqual childApp.get('test_value'), 1

    it '親appのset値は子appで上書きされる', ->
      # 関係する前に値が定義さている場合
      parentApp = express()
      childApp = express()
      parentApp.set 'test_value', 1
      childApp.set 'test_value', 2
      parentApp.use '/child', childApp
      assert.strictEqual parentApp.get('test_value'), 1
      assert.strictEqual childApp.get('test_value'), 2
      # 関係した後に値が定義さている場合
      parentApp = express()
      childApp = express()
      parentApp.use '/child', childApp
      childApp.set 'test_value', 2
      parentApp.set 'test_value', 1  # かつ、親が後にする
      assert.strictEqual parentApp.get('test_value'), 1
      assert.strictEqual childApp.get('test_value'), 2

    it '親子関係である複数app間でlocalsは共有されていない', ->
      parentApp = express()
      childApp = express()
      parentApp.locals = foo: true
      parentApp.use '/child', childApp
      assert not childApp?.locals.foo


  describe 'misc', ->

    it 'res.jsonとjsonpで返す値にundefinedが含まれていた場合はキーが削除される', (done) ->
      app = express()
      app.get '/json', (req, res, next) ->
        res.json
          x: null
          y: undefined
          nested:
            a: null
            b: undefined
      app.get '/jsonp', (req, res, next) ->
        res.json
          x: null
          y: undefined
          nested:
            a: null
            b: undefined

      async.series [
        (next) ->
          request app
            .get '/json'
            .expect 200
            .end (e, res) ->
              return next e if e
              assert.deepEqual JSON.parse(res.text),
                x: null
                nested:
                  a: null
              next()
        (next) ->
          request app
            .get '/jsonp'
            .expect 200
            .end (e, res) ->
              return next e if e
              assert.deepEqual JSON.parse(res.text),
                x: null
                nested:
                  a: null
              next()
      ], done
