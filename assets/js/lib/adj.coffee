class libAdj

  el = null
  $el = null
  ini = 0

  constructor: (expr) ->
    $el = if expr instanceof jQuery then expr else $ expr
    el = $el.get(0)
    $el.css overflow: 'hidden'
    ini = el.offsetHeight

    $el.on 'focus keydown keyup change', ->
      $el.css height: "#{ini}px"
      sh = el.scrollHeight
      while sh > el.scrollHeight
        sh = el.scrollHeight
        el.scrollHeight++
      if el.scrollHeight > el.offsetHeight
        $el.css height: "#{el.scrollHeight}px"


window.wiki or= {}
window.wiki.libAdj = libAdj