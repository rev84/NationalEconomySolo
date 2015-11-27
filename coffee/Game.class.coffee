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

  cards:{}

  @init:->
    super()
    @cards = {}
  @insert:(cardObj)->

class PrivateSpace extends SpaceBase
  @DIV_ID = "private"

  cards:{}

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
