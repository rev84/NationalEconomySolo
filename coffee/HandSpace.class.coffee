class HandSpace extends CardSpace
  @DIV_ID = "hand"

  # バルーンにつけるクラス
  @BALLOON_CLASS_NAME = 'balloon_hand'
  @BALLOON_GRAVITY = 'south'

  # 選択状態
  @SELECT_NOT   = 0
  @SELECT_LEFT  = 1
  @SELECT_RIGHT = 2

  @select : []

  @init:->
    super()
    @select = []

  # 選択状態を取得
  @getSelect:(index)->
    @select[index]
  # 選択状態を変更
  @clickLeft:(index)->
    if @select[index] is @SELECT_LEFT
      @select[index] = @SELECT_NOT
    else
      @select[index] = @SELECT_LEFT
  @clickRight:(index)->
    if @select[index] is @SELECT_RIGHT
      @select[index] = @SELECT_NOT
    else
      @select[index] = @SELECT_RIGHT
  # 選択状態を全解除
  @selectReset:->
    @select = []
    @select.push @SELECT_NOT for i in [0...@cards.length]

  # ソートする
  @sort:->
    @cards.sort()
    @select = []
    @selectReset()

  # 手札の数を取得
  @getAmount:->
    @cards.length

  # 手札を捨てる（墓地行きと、消滅）
  @trash:(trashCardIndexs, dropCardIndexs = [])->
    newCardNums = []
    trashCardNums = []
    for index in [0...@cards.length]
      if trashCardIndexs.in_array index
        trashCardNums.push @cards[index]
      else if dropCardIndexs.in_array index
      else
        newCardNums.push @cards[index]
    @cards = newCardNums
    Deck.trash trashCardNum for trashCardNum in trashCardNums

  # 手札を増やす
  @push:(cardNum)->
    @cards.push Number cardNum
    @select.push @SELECT_NOT

  # 描画(override)
  @redraw:->
    me = @getElement()

    me.html('')
    # バルーンも削除
    $('.'+@BALLOON_CLASS_NAME).remove()
    for index in [0...@cards.length]
      e = @createElement index
      me.append e if e isnt false
      e.addClass "card_select_left"  if @select[index] is @SELECT_LEFT
      e.addClass "card_select_right" if @select[index] is @SELECT_RIGHT

  # 左クリックで選択状態にする。
  @cardLeftClickAction:(elem) ->
    index = $(elem).attr('data-index')
    Game.handClickLeft Number index

  # 右クリックで選択状態にする。
  @cardRightClickAction:(elem) ->
    index = $(elem).attr('data-index')
    Game.handClickRight Number index

  # ダブルクリックで捨てる。
  @cardDoubleClickAction:(elem) ->
    index = $(elem).attr('data-index')
    Game.handDoubleClick Number index

  # 手札が持ち越し上限を超えているか
  @isHandOver:->
    @getAmount() > @getMax()

  # 所持できる最大枚数
  @getMax:->
    # 手札の最大枚数
    handMax = 5
    # 倉庫の数
    soukoNum = PrivateSpace.getAmountExistSouko()

    handMax + soukoNum*4

  # 所持している消費財の数
  @getAmountConsumer:->
    amount = 0
    for cardNum in @cards
      amount++ if Card.getClass(cardNum).isConsumer()
    amount
