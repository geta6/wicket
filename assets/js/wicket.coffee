window.wiki or= {}
window.wiki.helper or= {}
window.wiki.helper.pixel = (str) ->
  ($ 'body').append (el = $('<span>').addClass('wiki-test').text(str))
  width = el.width()
  el.remove()
  return width

window.wiki.helper.resize = ($el) ->
  width = (wiki.helper.pixel $el.val()) + 10
  return $el.css width: "#{width}px"

window.wiki.helper.location = ->
  uri = window.location.pathname.split "/"
  res = {}
  res.wiki = uri[1]
  res.article = uri.slice(2).join("/")
  console.log res.article
  return res

$ ->

  $elWrap = ($ '#wiki-wrap')
  $elEdit = ($ '#wiki-edit')
  $elBody = ($ '#wiki-body')

  inputlock = no

  caret = [0, 0]
  line = 0
  cols = 0

  others = {}

  path = wiki.helper.location()

  socket = io.connect 'http://localhost:3000'

  #ルーティングによりeventlistnerを設定
  #Backbone.jsとか使ったほうが良いんでしょうか？

  if path.wiki #ページリスト内
    socket.emit 'join',
      wiki: path.wiki
      article: path.article

    if path.article #編集可能領域内
      libime = new wiki.libIme $elEdit
      libadj = new wiki.libAdj $elBody
      update = (sync = yes, code = null) ->
        val = $elEdit.val()
        $elEdit.val ''
        if code is null
          # content update
          ini = $elBody.val().slice 0, caret[0]
          end = $elBody.val().slice caret[1]
          $elBody.val ini + val + end
          len = val.length
        else
          console.log code
          if code is 8
            len = -1
            ini = $elBody.val().slice 0, caret[0] - 1
            end = $elBody.val().slice caret[1]
            $elBody.val ini + end
        # info update
        caret = [caret[0]+= len, caret[1]+= len]
        lines = $elBody.val().slice(0, caret[0]).split '\n'
        line = lines.length
        cols = (_.last lines).length
        $elBody.focus()
        $elBody.get(0).selectionStart = caret[0]
        $elBody.get(0).selectionEnd = caret[1]
        $elEdit.css Measurement.caretPos $elBody
        $elEdit.focus()
        if sync
          socket.emit 'sync',
            caret: caret
            line: line
            cols: cols
            code: code
            pos: Measurement.caretPos $elBody
            val: val
        # console.log caret, line, cols
          # save db
          # 毎ストロークdbに保存するのは結構ヘビーなのでいいタイミングが欲しい
          socket.emit 'save',
            val: $('#wiki-body_dummy').html()
            key: window.location.pathname.slice(1).replace(/\//g,"%2F")


      socket.on 'sync', (data) ->
        unless others[data.id]?
          others[data.id] = ($ '<div>').addClass('vcaret')
          ($ 'body').append others[data.id]
        others[data.id].css data.pos
        data.caret = [data.caret[0]-data.val.length, data.caret[1]-data.val.length]
        ini = $elBody.val().slice 0, data.caret[0]
        end = $elBody.val().slice data.caret[1]
        $elBody.val ini + data.val + end
        if caret[0] < data.caret[0]
          caret = [caret[0]+data.val.length-1, caret[1]+data.val.length-1]
        if caret[0] > data.caret[0]
          caret = [caret[0]+data.val.length, caret[1]+data.val.length]
        $elEdit.css Measurement.caretPos $elBody
        $elBody.trigger 'change'
        unless inputlock
          update no
        else
          lock = setInterval ->
            unless inputlock
              clearInterval lock
              update no
          , 200

      $elWrap.on 'click', (event) ->
        if event.target.id is 'wiki-wrap'
          len = $elBody.val().length
          $elBody.focus()
          $elBody.get(0).selectionStart = len
          $elBody.get(0).selectionEnd = len
          caret = [len, len]
          update()
        else
          caret = [$elBody.get(0).selectionStart, $elBody.get(0).selectionEnd]
          update()
        $elEdit.css Measurement.caretPos $elBody
        $elEdit.focus()

      $elEdit.on 'keydown', ->
        wiki.helper.resize $elEdit
        return yes

      $elEdit.on 'keyup', (event) ->
        console.log event.keyCode
        if 0 < libime.status
          inputlock = no
          if libime.status isnt 3
            update yes
          else
            if event.keyCode is 8
              update yes, event.keyCode
        else
          inputlock = yes
        wiki.helper.resize $elEdit
