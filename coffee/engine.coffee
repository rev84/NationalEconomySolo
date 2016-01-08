$ ->
  if(DeviceChecker.isTouchDevice)
    srcHtml = './index-sm.html'
    srcCss = './css/index-sm.css'
  else
    srcHtml = './index-pc.html'
    srcCss = './css/index-pc.css'
  $.get(srcHtml, (data) ->
    $('head link:last').after('<link rel="stylesheet" type="text/css" href="' + srcCss + '">')
    $('#game').append(data)
    $('body').bind 'contextmenu', ->
      false
    Game.gameStart()
  )

# エラーハンドリング
window.onerror = (message, url, lineNo)->
  LogSpace.addScriptError(message, url, lineNo)
  true
