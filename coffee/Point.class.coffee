# 総得点
class Point extends SpaceBase
  @DIV_ID = 'point'

  @init:->
    @redraw 0

  # 描画
  @redraw:->
    @getElement().html Game.getPoint()
