###
Events

WIKI::INPUT::EMULATE
WIKI::INPUT::RETURN
WIKI::INPUT::


###

class Wicket

  # private jQuery objects
  $elTarget = ($ '#wiki-target')
  $elEditor = ($ '#wiki-editor')
  $elCarets = ($ '.wiki-caret')

  caretPosition = [0, 0]

  # private properties
  _directinput = no
  _editorsize = 0
  _socketif = null #interface


  # event hooks (updator)
  $elTarget.on 'keypress', ->
    _directinput = yes

  $elTarget.on 'keyup', (event) ->
    # detect IME
    ($ window).trigger 'WIKI::INPUT::STAY', event.keyCode
    return null if !_directinput and event.keyCode isnt 13
    ($ window).trigger 'WIKI::INPUT::RETURN',
      chars: $elTarget.text()
      width: $elTarget.width()
    $elTarget.text ''
    _directinput = no

  # $elEditor.on 'click', (event) ->
  #   $elTarget.focus()

  ($ window).on 'resize', ->
    _editorsize = $elEditor.innerWidth()

  ($ window).on 'click', (event) ->
    if event.target.id is 'wiki-editor'
      $elTarget.focus()
    else
      $elTarget.blur()

  # original events
  ($ window).on 'WIKI::INPUT::STAY', (event, code) ->
    if code < 65 or 90 < code
      console.log 'stay', code
      switch code
        when 8
          console.log 'backspace'

  ($ window).on 'WIKI::INPUT::RETURN', (event, data) ->
    $elEditor.text $elEditor.text() + data.chars
    console.log 'return', data.chars


  # public properties

  constructor: (uri) ->
    throw new Error 'io undefined, required socket.io' unless io
    _socketif = io.connect (uri || 'http://localhost:3000')
    ($ window).trigger 'resize'
    ($ window).trigger 'WIKI::FOCUS', { ini: 0, end: 0 }

  emulator: (code) ->


$ ->
  wicket = new Wicket()
