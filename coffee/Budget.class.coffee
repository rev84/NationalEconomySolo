# 家計
class Budget extends SpaceBase
  @DIV_ID = 'budget'

  @money : 0

  @init:->
    super()
    @money = 0
    @redraw()

  # 給料を払う
  @push:(amount)->
    return false if amount < 0
    @money += amount

  # 家計から徴収
  @pull:(amount)->
    return false if amount < 0
    return false if @money < amount
    @money -= amount

  # 金額を取得
  @getAmount:->
    @money

  # 描画
  @redraw:->
    @getElement().html '$ '+@getAmount()
