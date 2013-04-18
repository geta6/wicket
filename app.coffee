# module

http = require 'http'
path = require 'path'
express = require 'express'
connect =
  assets: require 'connect-assets'
  static: (require 'st')
    url: '/'
    path: path.resolve 'public'
    index: no
    passthrough: yes
_ = require 'underscore'

# app

app = express()
app.set 'port', process.env.PORT || 3000
app.set 'views', __dirname + '/views'
app.set 'view engine', 'jade'
app.use express.favicon()
app.use express.logger 'dev'
app.use express.bodyParser()
app.use express.methodOverride()
app.use connect.assets buildDir: 'public'
app.use connect.static
app.use app.router
app.use express.errorHandler()

# database

db = (require 'redis').createClient()

# route

routes = (require path.resolve 'routes') db
app.get '/',          routes.index
app.get '/:wiki',     routes.wiki
app.get '/:wiki/*',   routes.page
app.all '/*', (req, res) ->
  res.statusCode = 404
  res.render '404', 404


# server

server = http.createServer app
server.listen (app.get 'port'), ->
  (require 'child_process').exec 'which open && open http://localhost:3000'


# socket

io = (require 'socket.io').listen server

io.sockets.on 'connection', (socket) ->

  socket.on 'join', (uri) ->
    socket.join uri.path
    socket.set 'path', uri.path
    if uri.wiki
      socket.join uri.wiki
      socket.set 'wiki', uri.wiki


  socket.on 'sync', (data) ->
    socket.get "wiki", (err, wiki) ->
      socket.get "path", (err, path) ->
        #同じwiki内でページリストを参照しているsocketにemit
        socket.broadcast.to(wiki).emit 'update',data
        # 同じpathに居る場合、Sync
        if path
          data = _.extend data, id: socket.id
          socket.broadcast.to(path).emit 'sync',data


  socket.on 'save', (data) ->
    #タイムスタンプを基準にしたソート済みセットに格納
    date = new Date().getTime().toFixed()
    #console.log "key:"+data.key
    db.zadd data.key, date, data.val, (err, res) ->
      console.error err if err
      #console.log res

