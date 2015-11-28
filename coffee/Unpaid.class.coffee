# 未払い賃金
class Unpaid extends SpaceBase
  @DIV_ID = 'unpaid'

  @money : 0

  @init:->
    super()
    @money = 0
    @redraw()

  # 未払いを増やす
  @push:(amount)->
    return false if amount < 0
    @money += amount

  # 金額を取得
  @getAmount:->
    @money

  # 描画
  @redraw:->
    @getElement().html '$ '+@getAmount()
