client = require('mongodb').MongoClient
jsdom = require 'jsdom'
async = require 'async'
stemmer = require('porter-stemmer').stemmer

count = 0

parseToken = (pageDoc, pageCollection, callback) ->
  tokens = tokens || {}
  jsdom.env {
    html: pageDoc.raw
    url: pageDoc.url
    done: (err, win) ->
      try
        tokens = []
        for token in win.document.body.textContent.toLowerCase().split(/\s+/g)
          token = stemmer(token).replace(/[^a-zA-Z]/g, '')
          if token.length > 1 and token.length < 15
            tokens.push token
        pageCollection.update {_id: pageDoc._id}, {$set: {tokens: tokens}}, ->
          console.log ++count, pageDoc.url
      catch err
        pageCollection.remove {_id: pageDoc._id}, ->
          console.log err
      finally
        callback()
  }

client.connect "mongodb://localhost:27017/category", (err, db) ->
  not err and db.createCollection 'page', (err, pageCollection) ->
    pageCollection.find().toArray (err, docs) ->
      async.eachSeries docs, ((doc, callback) ->
        parseToken doc, pageCollection, callback
      ), (err) ->
        console.log 'all done'
