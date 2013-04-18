# routes

module.exports = (db) ->

  encode_params = (req) ->
    res = new Object
    res.wiki = encodeURIComponent req.params.wiki
    res.article = encodeURIComponent req.params[0]
    res.key = res.wiki+encodeURIComponent('/')+res.article
    return res

  index: (req, res) ->
    res.render 'index'

  wiki: (req, res) ->
    key = (encodeURIComponent req.params.wiki + '/') + '*'
    db.keys key, (err, reply) ->
      res.render 'list',
        wiki: req.params.wiki
        articles: reply || ''

  page: (req, res) ->
    param = encode_params req
    #とりあえずタイムスタンプの一番新しいモノだけ取得
    db.zrevrange param.key, 0, 0, (err, members) ->
      res.render 'article',
        wiki: param.wiki
        article: param.article
        content: if members then members[0] else ''
