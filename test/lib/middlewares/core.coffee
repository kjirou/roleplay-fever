async = require 'async'
{Model, Schema} = require 'mongoose'
assert = require 'power-assert'

{resetDatabase} = require 'helpers/database'
{createTestModel, createUniqueObjectId} = require 'helpers/test'
{applyObjectId, requireObjectId} = require 'lib/middlewares/core'


describe 'core middleware', ->

  before (done) -> resetDatabase done

  it 'applyObjectId', (done) ->
    createTestModel new Schema, (e, Test) ->
      mw = applyObjectId Test
      assert typeof mw is 'function'
      # テスト用に予め 2 docs 作成する
      ids = (createUniqueObjectId() for i in [0..1])
      async.eachSeries ids, (id, nextLoop) ->
        doc = new Test
        doc._id = id
        doc.save nextLoop
      , (e) ->
        Test.find (e, docs) ->
          assert docs.length is 2
          # ミドルウェアの機能で doc を自動取得できる
          req = {params:{id:ids[0].toString()}}
          mw req, {}, (e) ->
            assert req.doc instanceof Model
            assert req.doc._id.toString() is ids[0].toString()
            # もうひとつの id でも取得できる
            req.params.id = ids[1]
            mw req, {}, (e) ->
              assert req.doc instanceof Model
              assert req.doc._id.toString() is ids[1].toString()
              # ObjectId として不正なものは null
              req.params.id = undefined
              mw req, {}, (e) ->
                assert req.doc is null
                # 正しい ObjectId だがデータが存在しない :id
                req.params.id = createUniqueObjectId()
                mw req, {}, (e) ->
                  assert req.doc is null
                  done()

  it 'requireObjectId', (done) ->
    createTestModel new Schema, (e, Test) ->
      middleware = requireObjectId Test
      # :id が存在しない
      middleware {params:{}}, {}, (e) ->
        assert.strictEqual e.status, 404
        # 正しい :id だがデータが存在しない
        id = createUniqueObjectId()
        middleware {params:{id:id}}, {}, (e) ->
          assert.strictEqual e.status, 404
          done()
