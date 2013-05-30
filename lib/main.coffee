util = require './util'
crawler = require './crawler'
preprocessor = require './preprocessor'

util.getDb 'category', (err, db) ->
  util.getCollection db, 'page', (err, collection) ->
    crawler.craw 'http://stackoverflow.com/', collection, preprocessor.handler
