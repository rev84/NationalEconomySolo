class PublicSpace extends SpaceBase
  @DIV_ID = "public"

  # バルーンにつけるクラス
  @BALLOON_CLASS_NAME = 'balloon_public'

  @cards:[]
  # 建物の状態
  @status:[]

  @init:->
    super()
    @cards = []
    @status = []

  # すべて使用可能にする
  @resetStatus:->
    @status[index] = @STATUS_USABLE for index in [0...@cards.length]

  # カードクラスの取得
  @getCardClass:(index)->
    return Card.getClass(@cards[index])

  @isUsable:(index)->
    # 鉱山は無限に使える
    return true if @cards[index] is Card.CARD_NUM_KOUZAN
    # 存在しない
    return false unless @status[index]?
    # 使用可能状態でない
    return false if @status[index] isnt @STATUS_USABLE
    true

  # 労働者を置く
  @setWorked:(index)->
    return false if @isUsable index is false
    @status[index] = @STATUS_WORKED

  # 時間経過労働者を置く
  @setDisabled:(index)->
    return false if @isUsable index is false
    @status[index] = @STATUS_DISABLED

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

  # 最新の建物を使用不能にする
  @disableLastest:->
    for index in [@status.length-1..0]
      if @status[index] is @STATUS_USABLE
        @status[index] = @STATUS_DISABLED
        break

  # 描画
  @redraw:->
    me = @getElement()

    me.html('')
    # バルーンも削除
    $('.'+@BALLOON_CLASS_NAME).remove()
    for index in [0...@cards.length]
      e = @createElement index
      me.append e if e isnt false

  # ダブルクリック時には労働者を配置する
  @doubleClickAction:(elem)->
    index = $(elem).attr('data-index')
    Game.work 'public', index

  # 要素作成
  @createElement:(index)->
    # ハンドになければ脱出
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
    e = $('<div>').attr('data-index', index).addClass('card public')

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
    costBalloon = if cardClass.isPublicOnly() then '-' else cost
    priceBalloon = if cardClass.isPublicOnly() then '-' else price
    pointBalloon = if cardClass.isPublicOnly() then '-' else point
    catBalloon = if cat? then cat else 'なし'
    balloonStr = """
    #{desc}
    --------------------
    カテゴリ：#{catBalloon}
    コスト：#{costBalloon}
    売却価格：#{priceBalloon}
    得点：#{pointBalloon}
    """.replace /\n/g, '<br>'

    # darkTooltipはスマホに非対応。
    unless (DeviceChecker.isTouchDevice)
      e.attr('data-tooltip', balloonStr).darkTooltip(
        gravity : 'north'
        addClass : @BALLOON_CLASS_NAME
        )

    # 労働者により使用不可
    switch @status[index]
      when @STATUS_WORKED
        e.addClass('card_used') if @cards[index] isnt Card.CARD_NUM_KOUZAN
        e.append $('<img>').attr('src', @IMG_WORKER).addClass('card_worker')
      when @STATUS_DISABLED
        e.addClass('card_used')
        e.append $('<img>').attr('src', @IMG_DISABLER).addClass('card_worker')

    # クリックアクションを登録
    DeviceChecker.setDoubleClickAction(e, PublicSpace.doubleClickAction)

    e.append header
    e.append img
    e.append categorySpan
    e.append pointSpan
    e
