class HandSpace extends SpaceBase
  @DIV_ID = "hand"

  # バルーンにつけるクラス
  @BALLOON_CLASS_NAME = 'balloon_hand'

  # 選択状態
  @SELECT_NOT   = 0
  @SELECT_LEFT  = 1
  @SELECT_RIGHT = 2

  @cards : []
  @select : []

  @init:->
    super()
    @cards  = []
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

  # カード番号の取得
  @getCardNum:(index)->
    @cards[index]

  # カードクラスの取得
  @getCardClass:(index)->
    Card.getClass @getCardNum index

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

  # 描画
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

  # 要素作成
  @createElement:(index)->
    # ハンドになければ脱出
    return false unless @cards[index]?

    # カードのクラス
    cardClass = Card.getClass @cards[index]
    # カード名
    name = cardClass.getName()
    # カテゴリ
    cat = cardClass.getCategory()
    # コスト
    cost = cardClass.getCost()
    # 売却価格
    price = cardClass.getPrice()
    # 得点
    point = cardClass.getPoint()
    # 説明文
    desc = cardClass.getDescription()

    # カードの外側
    e = $('<div>').attr('data-index', index).addClass('card hand')

    # ヘッダ
    # [コスト]カード名
    header = $('<span>').addClass('card_header').html('['+cost+']'+cardClass.getName())

    # 画像
    img = cardClass.getImageObj().addClass('card_image')

    # フッタ
    # カテゴリ
    catStr = if cat? then '['+cat+']' else ''
    categorySpan = $('<span>').addClass('card_footer card_category').html(catStr)
    # 得点
    pointSpan = $('<span>').addClass('card_footer card_point').html('[$'+point+']')

    # 説明の吹き出し
    catBalloon = if cat? then cat else 'なし'
    balloonStr = """
    #{desc}
    --------------------
    カテゴリ：#{catBalloon}
    コスト：#{cost}
    売却価格：#{price}
    得点：#{point}
    """.replace /\n/g, '<br>'

    # darkTooltipはスマホに非対応。
    unless (DeviceChecker.isTouchDevice)
      e.attr('data-tooltip', balloonStr).darkTooltip(
        addClass : @BALLOON_CLASS_NAME
        )

    # 選択状態にする
    if (DeviceChecker.isTouchDevice)
      mc = new Hammer(e.get(0))
      e.on 'panleft', ->
        index = $(this).attr('data-index')
        Game.handClickLeft Number index
      e.on 'panright', ->
        index = $(this).attr('data-index')
        Game.handClickRight Number index
      # ダブルクリックにする
      e.on('touchend', (ev) ->
        ev.preventDefault()
      ).on('doubletap', ->
        index = $(this).attr('data-index')
        Game.handDoubleClick Number index
      )
    else
      e.on 'click', ->
        index = $(this).attr('data-index')
        Game.handClickLeft Number index
      e.on 'contextmenu', ->
        index = $(this).attr('data-index')
        Game.handClickRight Number index
      # ダブルクリックにする
      e.on 'dblclick', ->
        index = $(this).attr('data-index')
        Game.handDoubleClick Number index

    e.append header
    e.append img
    e.append categorySpan
    e.append pointSpan
    e

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
