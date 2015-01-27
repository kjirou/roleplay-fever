httpErrors = require 'http-errors'
_ = require 'lodash'
LocalStrategy = require('passport-local').Strategy

{User} = require 'apps/user/models'
{Field, Form} = require 'modules/validator'


@passportConfigurations =

  # passport.use へ渡す、新しくログインする際のログイン判定処理
  # passport.authenticate で生成したミドルウェアを実行した時に起動する
  localStrategy: ->
    new LocalStrategy {
      usernameField: 'email'
    }, (email, password, next) ->
      User.queryActiveUserByEmail(email).findOne (e, user) ->
        if e
          next e
        else if user?.verifyPassword password
          next null, user
        else
          next null, null

  # ログイン成功後に、セッションDBへその状態を格納する処理
  # passport.serializeUser へ設定する
  serializeUser: ->
    (user, callback) ->
      callback null, user._id.toString()

  # ログイン済みの場合に、セッションDBからログイン状態を復元する処理
  # passport.deserializeUser へ設定する
  deserializeUser: ->
    (userIdFromSession, callback) ->
      User.findOneById userIdFromSession, (e, user) ->
        return if e
          callback e
        # セッション上はログイン済みだが、User情報が削除されていた場合に
        # ログイン状態を解除する
        # Ref) https://github.com/jaredhanson/passport/issues/6#issuecomment-4857287
        else unless user
          callback null, false
        # e.g.
        #
        #   req.user = {
        #     user: User ドキュメント
        #   }
        #
        callback null,
          user: user

class UserForm extends Form
  constructor: ->
    super
    self = @
    @_user = null
    @field 'email', ((new Field)
      .type 'isRequired'
      .type 'isEmail'
      .type 'isLength', [1, 64]
      .custom ({value}, callback) ->
        User.queryActiveUserByEmail(value).findOne().exec (e, user) ->
          if e
            callback e
          else if not user or self._user?.email is value
            callback null, {isValid:true}
          else
            callback null, {isValid:false, message:'Duplicated email'}
    )
    @field 'password', ((new Field)
      .type 'isRequired'
      .type 'isAlphanumeric'
      .type 'isLength', [4, 16]
    )
  bindUser: (@_user) ->

@postUser = (user, values, callback) ->
  form = new UserForm values
  isNew = true
  if user
    isNew = false
    form.bindUser user
    form.getField('password').options.passIfEmpty = true
  else
    user = new User
  form.validate (e, validationResult) ->
    return callback e if e
    return callback null, validationResult unless validationResult.isValid
    user.email = values.email
    user.setPassword values.password if values.password
    user.save (e) ->
      callback null, user
