class window.Game
  @objs :
    public : null
    private : null
    hand : null
    log : null
    form : null
  @isSetObj : false

  @init : ->
    @setObj()
    obj.init() for name, obj of @objs

  @setObj : ->
    return if @isSetObj
    @isSetObj = true
    @objs.public = PublicSpace
    @objs.private = PrivateSpace
    @objs.hand = HandSpace
    @objs.log = LogSpace
    @objs.form = FormSpace

class SpaceBase
  @DIV_ID = null
  @init:->
    e = @getElement()
    e.html(@DIV_ID)

  @getElement:->
    $('#'+@DIV_ID)


class PublicSpace extends SpaceBase
  @DIV_ID = "public"

  cards:[]

  @init:->
    super()
    @cards = {}
  @insert:(cardObj)->

class PrivateSpace extends SpaceBase
  @DIV_ID = "private"

  cards:[]

  @init:->
    super()

class LogSpace extends SpaceBase
  @DIV_ID = "log"
  @init:->
    super()

class FormSpace extends SpaceBase
  @DIV_ID = "form"
  @init:->
    super()
class HandSpace extends SpaceBase
  @DIV_ID = "hand"
  @init:->
    super()

class RoundDeck
  @deck : []

  @init:->
    @deck = [
      5
      6
      7
      8
      9
      10
      11
      12
    ]
  @draw:->
    false if @deck.length is 0
    @deck.shift()

class Deck
  # 山札
  @deck : []
  # 墓地
  @grave : []

  @init:->
    @deck = []
    def = @getCardDefine()
    for cardNum, amount of def
      @deck.push cardNum for i in [0...amount]
    @shuffle()

    @grave = []

  @draw:->
    @recycle() if @deck.length is 0
    @deck.pop()

  @trash:(cardNum)->
    @grave.push cardNum

  @recycle:()->
    @deck.push cardNum for cardNum in @grave
    @grave = []
    @shuffle()

  @shuffle:->
    copy = []
    n = @deck.length
    while n
      i = Math.floor(Math.random() * n--)
      copy.push @deck.splice(i, 1)[0]
    @deck = copy
  @getCardDefine:->
    res =
      13 : 8
      14 : 4
      15 : 2
      16 : 2
      17 : 8
      18 : 4
      19 : 3
      20 : 3
      21 : 2
      22 : 1
      23 : 3
      24 : 2
      25 : 2
      26 : 2
      27 : 1
      28 : 3
      29 : 3
      30 : 2
      31 : 1
      32 : 1
      33 : 3
      34 : 2
      35 : 1
      36 : 1
    res