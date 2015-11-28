class LogSpace extends SpaceBase
  @DIV_ID = "log"
  @DIV_ID_PARENT = "log_space"
  @init:->
    super()
    @hide()

  # 消す
  @hide:->
    @getParentElement().hide()

  # メッセージを表示
  @show:(message)->
    @getElement().html(message)
    @getParentElement().show()

  # 徐々に消す
  @fadeout:(sec)->
    @getParentElement().fadeOut sec*1000

  # 親の要素を取得
  @getParentElement:->
    $('#'+@DIV_ID_PARENT)