class PrivateSpace extends SpaceBase
  @DIV_ID = "private"

  # バルーンにつけるクラス
  @BALLOON_CLASS_NAME = 'balloon_private'

  # 建物の状態の定数
  @STATUS_USABLE = 0
  @STATUS_WORKED = 1

  @cards:[]
  # 建物の状態
  @status:[]

  @init:->
    super()
    @cards = []
    @status = []

  # すべて使用可能にする
  @resetStatus:->
    @status = []
    @status[index] = @STATUS_USABLE for index in [0...@cards.length]

  # カード番号の取得
  @getCardNum:(index)->
    @cards[index]

  # カードクラスの取得
  @getCardClass:(index)->
    return Card.getClass @getCardNum index

  # 使用可能か
  @isUsable:(index)->
    # 存在しない
    return false unless @status[index]?
    # 使用可能状態でない
    return false if @status[index] isnt @STATUS_USABLE
    # そもそも置けない
    return false unless @getCardClass(index).isWorkable()
    true

  # 労働者を置く
  @setWorked:(index)->
    return false if @isUsable(index) is false
    @status[index] = @STATUS_WORKED

  # 資産の合計点を取得
  @getPoint:->
    point = 0
    for c in @cards
      cardClass = Card.getClass c
      point += cardClass.getPoint()
    point

  # 建物を配置する
  @push:(cardNum)->
    @cards.push Number cardNum
    @status.push @STATUS_USABLE

  # 建物を削除する
  # 返値は削除したカード番号
  @pull:(cardIndex)->
    newCards = []
    newStatus = []
    deletedCardNum = null
    for index in [0...@cards.length]
      # 削除するカード
      if index is cardIndex
        deletedCardNum = @cards[index]
      # その他
      else
        newCards.push @cards[index]
        newStatus.push @status[index]
    @cards = newCards
    @status = newStatus
    deletedCardNum

  # 描画
  @redraw:->
    me = @getElement()

    me.html('')
    # バルーンも削除
    $('.'+@BALLOON_CLASS_NAME).remove()
    for index in [0...@cards.length]
      e = @createElement index
      me.append e if e isnt false

  # 要素作成
  @createElement:(index)->
    # なければ脱出
    return false unless @cards[index]?

    # カードのクラス
    cardClass = @getCardClass index
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
    e = $('<div>').attr('data-index', index).addClass('card private')

    # ヘッダ
    # [コスト]カード名
    costStr = if cardClass.isPublicOnly() then '' else '['+cost+']'
    header = $('<span>').addClass('card_header').html(costStr+cardClass.getName())

    # 画像
    img = cardClass.getImageObj().addClass('card_image')

    # フッタ
    # カテゴリ
    catStr = if cat? then '['+cat+']' else ''
    categorySpan = $('<span>').addClass('card_footer card_category').html(catStr)
    # 得点
    pointStr = if cardClass.isPublicOnly() then '' else '[$'+point+']'
    pointSpan = $('<span>').addClass('card_footer card_point').html(pointStr)

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

    # 労働者により使用不可
    if @status[index] is @STATUS_WORKED
      e.addClass('card_used')
      e.append $('<img>').attr('src', @IMG_WORKER).addClass('card_worker')

    # ダブルクリック時
    if (DeviceChecker.isTouchDevice)
      e.on('touchend', (ev) ->
        ev.preventDefault()
      ).hammer().on('doubletap', ->
        # 通常時は労働者を派遣
        if Game.isClickable
          index = Number $(this).attr('data-index')
          Game.work 'private', index
        # 建物を売る
        else if Game.isSell
          index = Number $(this).attr('data-index')
          Game.sellPrivate index
      )
    else
      e.on 'dblclick', ->
        if Game.isClickable
          index = Number $(this).attr('data-index')
          Game.work 'private', index
        else if Game.isSell
          index = Number $(this).attr('data-index')
          Game.sellPrivate index



    e.append header
    e.append img
    e.append categorySpan
    e.append pointSpan
    e

  # 売れる建物があるか
  @isExistSellable:->
    # TODO:焼畑は売れる建物に含まれる前提
    for index in [0...@cards.length]
      cardClass = @getCardClass index
      return true if cardClass.isSellable()
    false

  # 所有する建物の数
  @getAmount:->
    @cards.length

  # 所有する法律事務所の数
  @getAmountHouritu:->
    amount = 0
    for cardNum in @cards
      amount++ if cardNum is Card.CARD_NUM_HOURITU
    amount

  # 所有する不動産屋の数
  @getAmountHudousan:->
    amount = 0
    for cardNum in @cards
      amount++ if cardNum is Card.CARD_NUM_HUDOUSAN
    amount

  # 所有する農協の数
  @getAmountNoukyou:->
    amount = 0
    for cardNum in @cards
      amount++ if cardNum is Card.CARD_NUM_NOUKYOU
    amount

  # 所有する労働組合の数
  @getAmountRouso:->
    amount = 0
    for cardNum in @cards
      amount++ if cardNum is Card.CARD_NUM_ROUSO
    amount

  # 所有する鉄道の数
  @getAmountRail:->
    amount = 0
    for cardNum in @cards
      amount++ if cardNum is Card.CARD_NUM_RAIL
    amount

  # 所有する本社ビルの数
  @getAmountBuilding:->
    amount = 0
    for cardNum in @cards
      amount++ if cardNum is Card.CARD_NUM_BUILDING
    amount

  # 所有する倉庫の数
  @getAmountExistSouko:->
    amount = 0
    for cardNum in @cards
      amount++ if cardNum is Card.CARD_NUM_SOUKO
    amount

  # 所有する社宅の数
  @getAmountExistSyataku:->
    amount = 0
    for cardNum in @cards
      amount++ if cardNum is Card.CARD_NUM_SYATAKU
    amount

  # 所有する施設カテゴリの数
  @getAmountInstitution:->
    amount = 0
    for cardNum in @cards
      amount++ if Card.getClass(cardNum).isInstitution()
    amount

  # 所有する農業カテゴリの数
  @getAmountFarming:->
    amount = 0
    for cardNum in @cards
      amount++ if Card.getClass(cardNum).isFarming()
    amount

  # 所有する工業カテゴリの数
  @getAmountIndustry:->
    amount = 0
    for cardNum in @cards
      amount++ if Card.getClass(cardNum).isIndustry()
    amount
