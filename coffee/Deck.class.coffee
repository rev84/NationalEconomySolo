class Deck extends SpaceBase
  @DIV_ID = 'deck'

  # 山札
  @deck : []
  # 墓地
  @grave : []

  @init:->
    @deck = []
    def = @getCardDefine()
    for cardNum, amount of def
      @deck.push Number cardNum for i in [0...amount]
    @shuffle()

    @grave = []

  # デッキの残り枚数を取得
  @getDeckLength:->
    @deck.length

  # カードを引く
  @pull:->
    @recycle() if @deck.length is 0
    @deck.shift()

  # カードを乗せる
  @place:(cardNum)->
    @deck.unshift Number cardNum

  # カードを捨てる
  @trash:(cardNum)->
    # 消費財は入れない
    return false if cardNum is Card.CARD_NUM_CONSUMER
    @grave.push Number cardNum

  # 墓地から山札に戻してシャッフル
  @recycle:()->
    @deck.push Number cardNum for cardNum in @grave
    @grave = []
    @shuffle()

  # シャッフル
  @shuffle:->
    copy = []
    n = @deck.length
    while n
      i = Math.floor(Math.random() * n--)
      copy.push @deck.splice(i, 1)[0]
    @deck = copy

  # カードの枚数定義
  @getCardDefine:->
    res =
      13 : 7  # 農場は1枚抜く
      14 : 4
      15 : 2
      16 : 2
      17 : 7  # 工場は1枚抜く
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

  # 描画
  @redraw:->
    @getElement().html @getDeckLength()
