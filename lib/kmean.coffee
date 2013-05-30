util = require './util'

squre = (x) -> x*x

distance = (v1, v2) ->
  keys = []
  euclidean = 0
  for key, value of v1
    keys.push key
    euclidean += squre(value - (v2[key] || 0))
  for key, value of v2
    if not keys.indexOf key
      euclidean += squre value
  return euclidean

weight = (vector, cluster) ->
  sum = 0
  for id, v of cluster
    sum += distance vector, v
  return sum

centric = (vectors) ->
  minial = {}
  for id, vector of vectors
    w = weight vector, vectors
    if minial.weight is undefined or w < minial.weight
      minial.weight = w
      minial.id = id
  return minial.id

recentric = (clusters) ->
  centriods = {}
  for cid, vectors of clusters
    newCid = centric(vectors)
    centriods[newCid] = vectors[newCid]
  return centriods

cluster = (centriods, vectors) ->
  clusters = {}
  for id, centriod of centriods
    clusters[id] = {}
  for vid, vector of vectors
    if not centriods[vid]
      minial = {distance: 100}
      for cid, centriod of centriods
        dis = distance centriod, vector
        if dis < minial.distance
          minial.id = cid
          minial.distance = dis
      clusters[minial.id][vid] = vector
    else
      clusters[vid][vid] = vector

  return clusters

util.getDb 'category', (err, db) ->
  util.getCollection db, 'page', (err, collection) ->
    collection.find({}, {fields: {tfidf: 1}}).toArray (err, docs) ->
      vectors = {}
      centriods = {}
      for doc in docs
        vectors[doc._id] = doc.tfidf
      for doc in docs.slice(100, 120)
        centriods[doc._id] = doc.tfidf
      centriods = recentric(cluster(centriods, vectors))
      centriods = recentric(cluster(centriods, vectors))
      clusters = cluster(centriods, vectors)
      result = {}
      for cid, vectors of clusters
        result[cid] = []
        for vid, vector of vectors
          result[cid].push(vid)
      console.log result
