fs = require 'fs'
client = require('mongodb').MongoClient

preprocess = ->
  client.connect "mongodb://localhost:27017/category", (err, db) ->
    not err and db.createCollection 'page', (err, pageCollection) ->
      not err and db.createCollection 'token', (err, tokenCollection) ->
        pageCollection.find({}, {fields: {tokens: 1}}).toArray (err, docs) ->
          mapping = {}
          for doc in docs
            for token in doc.tokens
              mapping[token] = mapping[token] or {}
              if mapping[token][doc._id]
                mapping[token][doc._id]++
              else
                mapping[token][doc._id] = 1
          fs.writeFileSync 'mapping', JSON.stringify(mapping), 'utf8'

calculate = ->
  mapping = JSON.parse(fs.readFileSync 'mapping', 'utf8')
  console.log mapping
  #n = docs.length
  #for doc in docs
    #do (doc) ->
      #tfidf = {}
      #for token, inverse of mapping
        #if inverse[doc._id]
          #tfidf[token] = Math.log(1+inverse[doc._id]) * Math.log(n/Object.keys(inverse).length)
        #else
          #tfidf[token] = 0
      #console.log Object.keys tfidf
      #pageCollection.update {_id: doc._id}, {$set: {tfidf: tfidf}}, (err, result) ->
        #console.log doc._id, 'done'
        
  #calculate()
preprocess()
