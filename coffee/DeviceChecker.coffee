class DeviceChecker

  @isTouchDevice = device.mobile() || device.tablet()

  @init:->
    if @isTouchDevice
      d = @doubleClickMessage()
      msg = """
      #{d}で労働者を派遣します。
      """ +
      '\nカードを長押しすると説明が見られます。'
      LogSpace.addInfoInstant(msg)

  @srcHtml = =>
    if @isTouchDevice then './index-sm.html' else './index-pc.html'

  @srcCss = =>
    if @isTouchDevice then './css/index-sm.css' else './css/index-pc.css'

  @leftClickMessage = =>
    if @isTouchDevice then "左フリック" else "左クリック"
  @rightClickMessage = =>
    if @isTouchDevice then "右フリック" else "右クリック"
  @doubleClickMessage = =>
    if @isTouchDevice then "ダブルタップ" else "ダブルクリック"

  @setDoubleClickAction:($elem, spaceAction) ->
    if @isTouchDevice
      $elem.on('touchend', (ev) ->
        ev.preventDefault()
      ).hammer().on('doubletap', ->
        spaceAction($elem)
      )
    else
      $elem.on 'dblclick', ->
        spaceAction($elem)

  @setLeftClickAction:($elem, spaceAction) ->
    if @isTouchDevice
      $elem.hammer().on('panleft', ->
        spaceAction($elem)
      )
    else
      $elem.on 'click', ->
        spaceAction($elem)

  @setRightClickAction:($elem, spaceAction) ->
    if @isTouchDevice
      $elem.hammer().on('panright', ->
        spaceAction($elem)
      )
    else
      $elem.on 'contextmenu', ->
        spaceAction($elem)

  @setTooltip:($elem, balloonStr, placement) ->
    if @isTouchDevice
      $elem.tooltip(
        html: true
        placement: placement
        title: balloonStr
        trigger: 'manual'
      )
      mc = new Hammer.Manager($elem[0], {
        recognizers: [
          [Hammer.Press, {time: 200}]
        ]
        })
      mc.on('press', ->
        $elem.tooltip('show')
      )
      mc.on('pressup', ->
        $elem.tooltip('hide')
      )
      return
    else
      $elem.tooltip(
        html: true
        placement: 'auto top'
        title: balloonStr
      )
      return
