class CardSpace extends SpaceBase

  # バルーンにつけるクラス
  @BALLOON_CLASS_NAME = null
  # バルーンの出る方向。デフォルトは下。
  @BALLOON_GRAVITY = 'north'

  # スペースにあるカード番号の配列
  @cards:[]

  @init:->
    @cards = []

  # カード番号の取得
  @getCardNum:(index)->
    @cards[index]

  # カードクラスの取得
  @getCardClass:(index)->
    return Card.getClass @getCardNum index

  # カードクリック時のアクション（デフォルトは何もしない）
  @cardLeftClickAction:(elem)->
    return
  @cardRightClickAction:(elem)->
    return
  @cardDoubleClickAction:(elem)->
    return

  # スペース固有のカードアクション
  @additionalCardAction:(elem, index)->
    return

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
    e = $('<div>').attr('data-index', index).addClass('card').addClass(@DIV_ID)

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

    # ツールチップを生成
    DeviceChecker.setTooltip(e, balloonStr, @BALLOON_CLASS_NAME, @BALLOON_GRAVITY)

    # クリックアクションを登録
    DeviceChecker.setLeftClickAction(e, @cardLeftClickAction)
    DeviceChecker.setRightClickAction(e, @cardRightClickAction)
    DeviceChecker.setDoubleClickAction(e, @cardDoubleClickAction)

    e.append header
    e.append img
    e.append categorySpan
    e.append pointSpan
    @additionalCardAction(e, index)
    e
