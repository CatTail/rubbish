client = require('mongodb').MongoClient
util = {}

util.getDb = (dbName, callback) ->
  client.connect "mongodb://localhost:27017/#{dbName}", (err, db) ->
    callback err, db

util.getCollection = (db, collectionName, callback) ->
  db.createCollection collectionName, (err, collection) ->
    callback err, collection

module.exports = util
