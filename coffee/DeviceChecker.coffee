class DeviceChecker

  @isTouchDevice = device.mobile() || device.tablet()

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
