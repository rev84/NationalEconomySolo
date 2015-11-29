class ButtonOK extends SpaceBase
  @DIV_ID = 'ok'
  @init:->
    @disable()
    @getElement().off 'click'
    @getElement().on 'click', ->
      Game.pushOK()

  @enable:->
    @getElement().prop("disabled", false).removeClass "disabled"

  @disable:->
    @getElement().prop("disabled", true).addClass "disabled"

class ButtonCANCEL extends SpaceBase
  @DIV_ID = 'cancel'
  @init:->
    @disable()
    @getElement().off 'click'
    @getElement().on 'click', ->
      Game.pushCANCEL()

  @enable:->
    @getElement().prop("disabled", false).removeClass "disabled"

  @disable:->
    @getElement().prop("disabled", true).addClass "disabled"

