class libIme

  el = null
  $el = null
  ime = yes
  num_up = 0
  num_pr = 0
  except = [8, 16, 17, 18, 37, 38, 39, 40, 91]

  status: 0

  constructor: (expr) ->
    $el = if expr instanceof jQuery then expr else $ expr
    el = $el.get(0)

    ev = 'addEventListener'
    ev = 'on' if jQuery?

    $el.on 'keydown', (event) =>
      ime = yes
      num_pr = 0
      num_up = 0
      return yes

    $el.on 'keypress', (event) =>
      ime = no
      num_pr++
      return yes

    $el.on 'keyup', (event) =>
      num_up++
      if (except.indexOf event.keyCode) is -1
        if ime and event.keyCode is 13
          @status = 1
        else if ime and num_pr < num_up
          @status = 0
        else
          @status = 2
      else
        @status = 3
      return yes

window.wiki or= {}
window.wiki.libIme = libIme