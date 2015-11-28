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
    # 存在しない
    return false unless @status[index]?
    # 使用可能状態でない
    return false if @status[index] isnt @STATUS_USABLE
    true

  @setWorked:(index)->
    return false if @isUsable index is false
    @status[index] = @STATUS_WORKED

  @setDisabled:(index)->
    return false if @isUsable index is false
    @status[index] = @STATUS_DISABLED

  # 建物を配置する
  @push:(cardNum)->
    @cards.push Number cardNum
    @status.push @STATUS_USABLE

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
    e = $('<div>').attr('data-index', index).addClass('public')

    # ヘッダ
    # [コスト]カード名
    costStr = if cardClass.isPublicOnly() then '' else '['+cost+']'
    header = $('<span>').addClass('public_header').html(costStr+cardClass.getName())

    # 画像
    img = cardClass.getImageObj().addClass('public_image')

    # フッタ
    # カテゴリ
    catStr = if cat? then '['+cat+']' else ''
    categorySpan = $('<span>').addClass('public_footer public_category').html(catStr)
    # 得点
    pointStr = if cardClass.isPublicOnly() then '' else '[$'+point+']'
    pointSpan = $('<span>').addClass('public_footer public_point').html(pointStr)

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
    e.attr('data-tooltip', balloonStr).darkTooltip(
      gravity : 'north'
      addClass : @BALLOON_CLASS_NAME
    )

    # 労働者により使用不可
    switch @status[index]
      when @STATUS_WORKED
        e.addClass('used')
        e.append $('<img>').attr('src', @IMG_WORKER).addClass('worker')
      when @STATUS_DISABLED
        e.addClass('used')
        e.append $('<img>').attr('src', @IMG_DISABLER).addClass('worker')


    # ダブルクリック時には使用する
    e.dblclick ->
      index = Number $(this).attr('data-index')
      Game.work 'public', index

    e.append header
    e.append img
    e.append categorySpan
    e.append pointSpan
    e
