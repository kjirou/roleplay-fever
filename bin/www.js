#!/usr/bin/env node

require('coffee-script/register');

require('../env/development');


var http = require('http');

var app = require('app');
var conf = require('conf');
var logger = require('lib/logger')();


var port = parseInt(conf.server.port, 10);
var server = http.createServer(app);

server.on('error', function(error){
  if (error.syscall !== 'listen') {
    throw error;
  }

  // handle specific listen errors with friendly messages
  switch (error.code) {
    case 'EACCES':
      logger.error('Port ' + port + ' requires elevated privileges');
      process.exit(1);
      break;
    case 'EADDRINUSE':
      logger.error('Port ' + port + ' is already in use');
      process.exit(1);
      break;
    default:
      throw error;
  }
});

server.on('listening', function(){
  logger.log('Listening on port ' + server.address().port);
});

server.listen(port);
