class CardBase
  element  = null

  isTap    = false
  isWorker = false

  constructor:(@gameObj, @cardNum)->
  getCardNum:()->
    @cardNum
  tap:()->
  use:()->
  movePublic:()->

class CardKouzan extends CardBase

