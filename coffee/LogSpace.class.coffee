class LogSpace extends SpaceBase
  @DIV_ID = "log"
  @init:->
    super()
    @clear()

  # ログのクリア
  @clear:->
    @getElement().html('')
  # 通常のログ
  @output:(message)->
  # エラーログ
  @error:(message)->
  # 致命的なエラーログ
  @fatal:(message)->
