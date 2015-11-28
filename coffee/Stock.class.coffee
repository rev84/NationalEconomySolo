# 資産
class Stock extends SpaceBase
  @DIV_ID = 'stock'

  @money : 5

  @init:->
    super()
    @money = 5
    @redraw()

  # 資金をもらう
  @push:(amount)->
    return false if amount < 0
    @money += amount

  # 資金を失う（0で維持する）
  @pull:(amount)->
    return false if amount < 0

    @money -= amount
    @money = if @money < 0 then 0 else @money

  # 金額を取得
  @getAmount:->
    @money

  # 描画
  @redraw:->
    @getElement().html '$ '+@getAmount()
