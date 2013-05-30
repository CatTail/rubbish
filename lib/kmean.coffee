util = require './util'

squre = (x) -> x*x

distance = (v1, v2) ->
  keys = []
  euclidean = 0
  for key, value of v1
    keys.push key
    euclidean += squre(value) + squre(v2[key] || 0)
  for key, value of v2
    if not keys.indexOf key
      euclidean += squre value
  return euclidean

util.getDb 'category', (err, db) ->
  util.getCollection db, 'page', (err, collection) ->
    collection.find({}, {fields: {tfidf: 1}}).toArray (err, docs) ->
      clusters = {}
      centriods = docs.slice(100, 120)
      for centriod in centriods
        clusters[centriod._id] = []

      for doc in docs
        minial = {distance: 100}
        for centriod in centriods
          dis = distance centriod.tfidf, doc.tfidf
          if dis < minial.distance
            minial._id = centriod._id
            minial.distance = dis
        clusters[minial._id].push(doc._id)
      console.log clusters
