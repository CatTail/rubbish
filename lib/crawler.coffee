http = require 'http'
crawler = {}

fetch = (target, collection, handler) ->
  req = http.get target, (res) ->
    if res.statusCode is 200
      data = ''
      res.setEncoding 'utf8'
      res.on 'data', (d) ->
        data += d
      res.on 'end', ->
        handler target, collection, data, (url) ->
          fetch url, collection, handler
  req.on 'error', (err) ->
    console.log err

crawler.craw = (target, collection, handler) ->
  fetch target, collection, handler

module.exports = crawler
