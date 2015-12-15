$ ->
  $('body').bind 'contextmenu', ->
    false
  Game.gameStart()

# エラーハンドリング
window.onerror = (message, url, lineNo)->
  LogSpace.addScriptError(message, url, lineNo)
  true
