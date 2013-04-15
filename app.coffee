# module

http = require 'http'
path = require 'path'
express = require 'express'
connect =
  assets: require 'connect-assets'
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
app.use app.router
app.use express.static path.resolve 'public'
app.use express.errorHandler()


# route

app.get '/', (req, res) ->
  res.render 'index', title: 'hoge'


# server

server = http.createServer app
server.listen (app.get 'port'), ->
  (require 'child_process').exec 'which open && open http://localhost:3000'


# socket

io = (require 'socket.io').listen server

io.sockets.on 'connection', (socket) ->
  socket.on 'sync', (data) ->
    data = _.extend data, id: socket.id
    socket.broadcast.emit 'sync', data
