# routes

module.exports = (app,db) ->

   #  index
  app.get '/', (req, res) ->
    res.render "index"

  # lib
  app.get '/lib/:path', (req,res) ->
    res.sendfile('./public/lib/' + req.params.path)

   #  ページ一覧
  app.get '/:wiki', (req, res)->
    console.log "dbkey:"+encodeURIComponent(req.params.wiki+"/")
    db.keys encodeURIComponent(req.params.wiki+"/")+'*', (err, reply) ->
      reply = "" unless reply
      res.render "list", { wiki: req.params.wiki, articles:reply }

  #  記事
  app.get '/:wiki/*', (req, res) ->
    param = encode_params(req)
    console.log "param:"+param.key
    #とりあえずタイムスタンプの一番新しいモノだけ取得
    db.zrevrange param.key,0,0, (err,members) ->
      if members is undefined
        res.render "article", { wiki:param.wiki, article:param.article,content:"" }
      else
        res.render "article",{ wiki:param.wiki, article:param.article, content:members[0]  }

  # If all else failed, show 404 page
  app.all '/*', (req, res) ->
    console.warn "error 404: ", req.url
    res.statusCode = 404
    res.render '404', 404

  encode_params = (req) ->
    res = new Object
    res.wiki = encodeURIComponent req.params.wiki
    res.article = encodeURIComponent req.params[0]
    res.key = res.wiki+encodeURIComponent('/')+res.article
    return res