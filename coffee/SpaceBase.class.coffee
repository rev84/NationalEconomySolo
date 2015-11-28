class SpaceBase
  @DIV_ID = null
  # 建物の状態の定数
  @STATUS_USABLE   = 0
  @STATUS_WORKED   = 1
  @STATUS_DISABLED = 2
  # 画像のパス
  @IMG_DISABLER = './img/disabler.png'
  @IMG_WORKER   = './img/worker.png'

  @init:->
    e = @getElement()
    e.html(@DIV_ID)

  @getElement:->
    $('#'+@DIV_ID)
