fs = require 'fs'
path = require 'path'
url = require 'url'
jsdom = require 'jsdom'
async = require 'async'
stemmer = require('porter-stemmer').stemmer
preprocessor = {}

count = 0
dir = './pages'
preprocessor.handler = (target, collection, data, next) ->
  collection.findOne {url: target}, (err, doc) ->
    if not err and not doc
      if count < 10000
        console.log ++count, target
        collection.insert {url: target}, (err, result) ->
          _id = result[0]._id
          fs.writeFileSync path.join(dir, _id.toString()), data, 'utf8'
          jsdom.env {
            html: data
            url: target
            done: (err, win) ->
              try
                tokens = []
                for token in win.document.body.textContent.toLowerCase().split(/\s+/g)
                  token = stemmer(token).replace(/[^a-zA-Z]/g, '')
                  if token.length > 1 and token.length < 15
                    tokens.push token
                collection.update {_id: _id}, {$set: {tokens: tokens}}, ->
              catch err
                collection.remove {_id: _id}, ->
                  console.log err
              for a in win.document.getElementsByTagName('a')
                if url.parse(a.href).protocol is 'http:'
                  next a.href
          }

module.exports = preprocessor
