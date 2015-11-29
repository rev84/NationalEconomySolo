$ ->
  $('body').bind 'contextmenu', ->
    false
  Game.gameStart()