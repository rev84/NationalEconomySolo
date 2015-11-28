Array::in_array = (target)->
  for index in [0...@length]
    return true if @[index] is target
  false
