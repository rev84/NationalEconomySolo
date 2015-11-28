class Worker extends SpaceBase
  @DIV_ID = 'worker'

  @active : 0
  @max : 0

  @init:->
    super()
    @active = 2
    @max    = 2
    @redraw()

  # 労働者の総計
  @getTotal:->
    @max

  # 使用可能な労働者
  @getActive:->
    @active

  # 労働者を追加
  @add:(isActiveNow = false)->
    @max++
    @active++ if isActiveNow
    @redraw()

  # すべての労働者をアクティブに
  @wake:->
    @active = @max
    @redraw()

  # アクティブな労働者を使用
  @work:->
    return false if @active <= 0
    @active--
    @redraw()

  # 描画
  @redraw:->
    @getElement().html ''+@active+' / '+@max
