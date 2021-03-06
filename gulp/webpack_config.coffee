webpackStream = require 'webpack-stream'

NormalModuleReplacementPlugin = webpackStream.webpack.NormalModuleReplacementPlugin

class WebpackConfig

  getDefaultConfiguration: ->
    module:
      loaders: [
        {test: /\.coffee$/i, loader: 'coffee-loader'}
      ]
      noParse: [
        /node_modules\/sinon\/pkg\/.*/
      ]
    resolve:
      extensions: ['', '.js', '.coffee']
    plugins: [
      new NormalModuleReplacementPlugin /^sinon$/, process.cwd() + '/node_modules/sinon/pkg/sinon.js'
    ]

module.exports = new WebpackConfig
