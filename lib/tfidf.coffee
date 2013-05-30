util = require './util'
async = require 'async'

console.log 'tfidf'
count = 0
util.getDb 'category', (err, db) ->
  util.getCollection db, 'page', (err, collection) ->
    collection.find({}, {fields: {tokens: 1}}).toArray (err, docs) ->
      tokens = []
      mapping = {}
      for doc in docs
        if doc.tokens # some doc have fetch for tokens
          for token in doc.tokens
            mapping[token] = mapping[token] or {}
            if mapping[token][doc._id]
              mapping[token][doc._id]++
            else
              mapping[token][doc._id] = 1
              tokens.push token
      
      # tfidf weight
      async.each docs, ((doc, callback) ->
        tfidf = {}
        for token, inverse of mapping
          if inverse[doc._id]
            tfidf[token] = Math.log(1+inverse[doc._id]) * Math.log(docs.length/Object.keys(inverse).length)
        # normalize
        distance = 0
        for token, weight of tfidf
          distance += weight*weight
        distance = Math.sqrt distance
        for token of tfidf
          tfidf[token] = tfidf[token] / distance

        collection.update {_id: doc._id}, {$set: {tfidf: tfidf}}, ->
          console.log ++count, doc._id
          callback()
      ), ->
        db.close()
