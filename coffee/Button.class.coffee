class ButtonOK extends SpaceBase
  @DIV_ID = 'ok'
  @init:->
    @disable()

  @enable:->
    @getElement().prop("disabled", false).removeClass "disabled"

  @disable:->
    @getElement().prop("disabled", true).addClass "disabled"

class ButtonCANCEL extends SpaceBase
  @DIV_ID = 'cancel'
  @init:->
    @disable()

  @enable:->
    @getElement().prop("disabled", false).removeClass "disabled"

  @disable:->
    @getElement().prop("disabled", true).addClass "disabled"

