var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var express = require('express');
var session = require('express-session');
var httpErrors = require('http-errors');
var _ = require('lodash');
var logger = require('morgan');
var passport = require('passport');
var LocalStrategy = require('passport-local').Strategy;
var path = require('path');
var favicon = require('serve-favicon');

var apps = require('apps');
var passportConfigurations = require('apps/user/logics').passportConfigurations;
var conf = require('conf');


var app = express();


//
// view engine setup
//
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');


//
// common locals
//
app.locals = {
  basedir: conf.viewRoot
};


//
// passport configurations
//
passport.use(passportConfigurations.localStrategy());
passport.serializeUser(passportConfigurations.serializeUser());
passport.deserializeUser(passportConfigurations.deserializeUser());


//
// middlewares
//
// uncomment after placing your favicon in /public
//app.use(favicon(__dirname + '/public/favicon.ico'));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));
app.use(session({
  resave: false,
  saveUninitialized: false,
  secret: conf.session.secret,
  cookie: {
    maxAge: 365 * 24 * 60 * 60 * 1000
  },
  store: conf.session.mongodbStore.prepareConnection()
}));
app.use(passport.initialize());
app.use(passport.session());
app.use('/', apps.subApps.core);


//
// handle errors
//

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(httpErrors(404));
});

// error handlers
if (conf.env === 'development') {
  app.use(function(err, req, res, next) {
    res.status(err.status);
    res.render('apps/error', {
      message: err.message,
      error: err
    });
  });
} else {
  app.use(function(err, req, res, next) {
    res.status(err.status);
    res.render('apps/error', {
      message: err.message,
      error: {}
    });
  });
}


module.exports = app;
