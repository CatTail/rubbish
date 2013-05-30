client = require('mongodb').MongoClient

client.connect "mongodb://localhost:27017/category", (err, db) ->
  not err and db.createCollection 'page', (err, pageCollection) ->
    pageCollection.find({}, {fields: {tfidf: 1}}).toArray (err, docs) ->
      console.log docs.length
      #for doc in docs
        #console.log 1

