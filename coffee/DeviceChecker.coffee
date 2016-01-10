class DeviceChecker

  @isTouchDevice = device.mobile() || device.tablet()

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

  @setTooltip:($elem, balloonStr, tooltipClassName, gravity) ->
    if @isTouchDevice
      return
    else
      $elem.attr('data-tooltip', balloonStr).darkTooltip(
        gravity : gravity
        addClass : tooltipClassName
      )
      return
