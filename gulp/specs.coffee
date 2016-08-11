mocha = require 'gulp-mocha'
webpack = require 'webpack-stream'
runSequence = require 'run-sequence'
karmaServer = require('karma').Server

require 'coffee-loader'

module.exports = (gulp) ->
  gulp.task 'specs', (callback) ->
    runSequence 'specs:server', 'specs:client', callback


  gulp.task 'specs:server', ->
    gulp.src [
      'src/spec_setup.coffee'
      'src/**/*.coffee'
    ]
    .pipe mocha()


  gulp.task 'specs:client', ->
    runSequence 'specs:client:build', 'specs:client:run'


  gulp.task 'specs:client:build', ->
    webpackConfig = require('./webpack_config').getDefaultConfiguration()
    webpackConfig.output =
      filename: 'specs.js'

    gulp.src [
      'src/spec_setup.coffee'
      'src/**/*.coffee'
    ]
    .pipe webpack webpackConfig
    .pipe gulp.dest 'dist/specs'


  gulp.task 'specs:client:run', (done) ->
    new karmaServer(
      configFile: "#{__dirname}/../karma.conf.js"
    , done).start()
