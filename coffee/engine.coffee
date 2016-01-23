$ ->
  $('head link:last').after('<link rel="stylesheet" type="text/css" href="' + DeviceChecker.srcCss() + '">')
  $('body').bind 'contextmenu', ->
    false
  $.get(DeviceChecker.srcHtml(), (data) ->
    $('#game').append(data)
    Game.gameStart()
  )

# エラーハンドリング
window.onerror = (message, url, lineNo)->
  LogSpace.addScriptError(message, url, lineNo)
  true
