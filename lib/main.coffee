util = require './util'
crawler = require './crawler'
preprocessor = require './preprocessor'

util.getDb 'category', (err, db) ->
  util.getCollection db, 'page', (err, collection) ->
    crawler.craw 'http://www.yahoo.com/', collection, preprocessor.handler
