class LogSpace extends SpaceBase
  @DIV_ID = "log_space"
  @DIV_CLASS = 'log'
  @DIV_INFO_CLASS = 'log_info'
  @DIV_WARN_CLASS = 'log_warn'
  @DIV_FATAL_CLASS = 'log_fatal'

  @init:->
    super()
    @removeAll()

  # 固定をすべて消す
  @removeAll:->
    $('.'+@DIV_CLASS).remove()

  # 固定の警告メッセージを表示
  @addFatal:(message)->
    e = $('<div>').addClass(@DIV_CLASS+' '+@DIV_FATAL_CLASS).html(message)
    @getElement().append e

  # 固定の忠告メッセージを表示
  @addWarn:(message)->
    e = $('<div>').addClass(@DIV_CLASS+' '+@DIV_WARN_CLASS).html(message)
    @getElement().append e

  # 固定の通常メッセージを表示
  @addInfo:(message)->
    e = $('<div>').addClass(@DIV_CLASS+' '+@DIV_INFO_CLASS).html(message)
    @getElement().append e

  # 徐々に消える警告メッセージを表示
  @addFatalInstant:(message, sec = 5)->
    e = $('<div>').addClass(@DIV_FATAL_CLASS).html(message)
    @getElement().append e
    e.fadeOut sec*1000
    setTimeout e.remove, sec*1000

  # 徐々に消える忠告メッセージを表示
  @addWarnInstant:(message, sec = 5)->
    e = $('<div>').addClass(@DIV_WARN_CLASS).html(message)
    @getElement().append e
    e.fadeOut sec*1000
    setTimeout e.remove, sec*1000

  # 徐々に消える通常メッセージを表示
  @addInfoInstant:(message, sec = 5)->
    e = $('<div>').addClass(@DIV_INFO_CLASS).html(message)
    @getElement().append e
    e.fadeOut sec*1000
    setTimeout e.remove, sec*1000

