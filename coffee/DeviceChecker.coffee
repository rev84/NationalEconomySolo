class DeviceChecker

  @isTouchDevice = device.mobile() || device.tablet()

  @leftClickMessage = =>
    if @isTouchDevice then "左フリック" else "左クリック"
  @rightClickMessage = =>
    if @isTouchDevice then "右フリック" else "右クリック"
  @doubleClickMessage = =>
    if @isTouchDevice then "ダブルタップ" else "ダブルクリック"