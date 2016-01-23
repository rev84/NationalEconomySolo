class LogSpace extends SpaceBase
  @DIV_ID = "log_space"
  @DIV_CLASS = 'log'
  @DIV_INFO_CLASS = 'log_info'
  @DIV_WARN_CLASS = 'log_warn'
  @DIV_FATAL_CLASS = 'log_fatal'
  @DIV_SCRIPT_ERROR_CLASS = 'log_script_error'
  @MESSAGE_CLASS = 'log_message'

  @IMG_INFO = './img/info.png'
  @IMG_WARN = './img/warning.png'
  @IMG_FATAL = './img/fatal.png'

  @init:->
    super()
    @removeAll()

  # 固定をすべて消す
  @removeAll:->
    $('.'+@DIV_CLASS).remove()

  # 固定の警告メッセージを表示
  @addFatal:(message)->
    e = $('<div>').addClass(@DIV_CLASS+' '+@DIV_FATAL_CLASS)
    msg = $('<span>').addClass(@MESSAGE_CLASS).html(message)
    @getElement().append(e.append(msg))


  # 固定の忠告メッセージを表示
  @addWarn:(message)->
    e = $('<div>').addClass(@DIV_CLASS+' '+@DIV_WARN_CLASS)
    msg = $('<span>').addClass(@MESSAGE_CLASS).html(message)
    @getElement().append(e.append(msg))

  # 固定の通常メッセージを表示
  @addInfo:(message)->
    e = $('<div>').addClass(@DIV_CLASS+' '+@DIV_INFO_CLASS)
    msg = $('<span>').addClass(@MESSAGE_CLASS).html(message)
    @getElement().append(e.append(msg))

  # 徐々に消える警告メッセージを表示
  @addFatalInstant:(message, sec = 5)->
    e = $('<div>').addClass(@DIV_CLASS+' '+@DIV_FATAL_CLASS)
    msg = $('<span>').addClass(@MESSAGE_CLASS).html(message)
    @getElement().append(e.append(msg))
    e.fadeOut sec*1000
    setTimeout e.remove, sec*1000

  # 徐々に消える忠告メッセージを表示
  @addWarnInstant:(message, sec = 5)->
    e = $('<div>').addClass(@DIV_CLASS+' '+@DIV_WARN_CLASS)
    msg = $('<span>').addClass(@MESSAGE_CLASS).html(message)
    @getElement().append(e.append(msg))
    e.fadeOut sec*1000
    setTimeout e.remove, sec*1000

  # 徐々に消える通常メッセージを表示
  @addInfoInstant:(message, sec = 5)->
    e = $('<div>').addClass(@DIV_CLASS+' '+@DIV_INFO_CLASS)
    msg = $('<span>').addClass(@MESSAGE_CLASS).html(message)
    @getElement().append(e.append(msg))
    e.fadeOut sec*1000
    setTimeout e.remove, sec*1000


  # 固定のスクリプトエラーを表示
  @addScriptError:(message, url, lineNo)->
    txt = """
    スクリプトエラーが発生しました。
    申し訳ありませんが、<a href="https://twitter.com/rev84" target="_blank">@rev84</a>まで、以下のメッセージや、スクリーンショットを送っていただけると助かります。
    <hr>
    [message]
    #{message}
    [url]
    #{url}
    [lineNo]
    #{lineNo}
    """.replace /\n/g, '<br>'
    e = $('<div>').addClass(@DIV_SCRIPT_ERROR_CLASS).html(txt)
    @getElement().append e
