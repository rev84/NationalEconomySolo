class RoundDeck extends SpaceBase
  @DIV_ID : 'round'

  @ROUND_MAP :
    1 : 2
    2 : 2
    3 : 3
    4 : 3
    5 : 3
    6 : 4
    7 : 4
    8 : 5
    9 : 5
    10 : 0

  @deck : []
  @round : 0

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
    @round = 1

  # カードを引く
  @pull:->
    false if @deck.length is 0
    @deck.shift()

  # 現在のラウンドを取得
  @getRound:->
    @round

  # 現在の給料を取得
  @getSalary:->
    @ROUND_MAP[@getRound()]

  # ラウンドを進める
  @addRound:->
    @round++
  # ゲーム終了しているか
  @isGameEnd:->
    @round > 9

  # ラウンド/給料の表示を更新
  @redraw:->
    @getElement().html ''+@getRound()+' / $'+@getSalary()