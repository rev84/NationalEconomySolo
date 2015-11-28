class RoundDeck
  @deck : []

  @init:->
    @deck = [
      2
      3
      4
      13
      5
      6
      7
      8
      9
      10
      11
      12
    ]

  # カードを引く
  @pull:->
    false if @deck.length is 0
    @deck.shift()
