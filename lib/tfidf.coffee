client = require('mongodb').MongoClient

client.connect "mongodb://localhost:27017/category", (err, db) ->
  not err and db.createCollection 'page', (err, pageCollection) ->
    pageCollection.find({}, {fields: {tokens: 1}}).toArray (err, docs) ->
      mapping = {}
      for doc in docs
        for token in doc.tokens
          mapping[token] = mapping[token] or {}
          if mapping[token][doc._id]
            mapping[token][doc._id]++
          else
            mapping[token][doc._id] = 1

      n = docs.length
      for doc in docs
        do (doc) ->
          tfidf = {}
          for token, inverse of mapping
            if inverse[doc._id]
              tfidf[token] = Math.log(1+inverse[doc._id]) * Math.log(n/Object.keys(inverse).length)
          pageCollection.update {_id: doc._id}, {$set: {tfidf: tfidf}}, (err, result) ->
            console.log doc._id, 'done'
