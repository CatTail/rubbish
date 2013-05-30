http = require 'http'
url = require 'url'
path = require 'path'
jsdom = require 'jsdom'
async = require 'async'
client = require('mongodb').MongoClient

count = 0

fetchUrl = (target, pageCollection) ->
  pageCollection.find({url: target}).toArray (err, docs) ->
    if not err and not docs.length
      if count < 10000
        console.log ++count, target
        data = ''
        req = http.get target, (res) ->
          res.setEncoding 'utf8'
          res.on 'data', (d) ->
            data += d

          res.on 'end', ->
            pageCollection.insert {url: target, raw: data}, (err, result) ->
              if err
                throw 'Something wrong in collection insertion'

              jsdom.env {
                html: data
                url: target
                done: (err, win) ->
                  for a in win.document.getElementsByTagName('a')
                    if path.extname(url.parse(a.href).pathname) is '.html' and url.parse(a.href).protocol is 'http:'
                      fetchUrl a.href, pageCollection
              }
        req.on 'error', (err) ->
          console.log err


client.connect "mongodb://localhost:27017/category", (err, db) ->
  not err and db.createCollection 'page', (err, pageCollection) ->
    fetchUrl 'http://www.yahoo.com', pageCollection
