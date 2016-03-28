$ ->
  # IEは非対応
  ua = window.navigator.userAgent.toLowerCase()
  unless ua.indexOf("msie") is -1 and ua.indexOf("trident/7.0") is -1
    alert """
          Internet Explorer には対応しておりません。
          Google Chrome などのブラウザを使用して下さい。
          """
    return

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
