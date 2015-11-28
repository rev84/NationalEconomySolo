class PrivateSpace extends SpaceBase
  @DIV_ID = "private"

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
    @status[index] = @STATUS_USABLE for index in [0...@cards.length]

  # カードクラスの取得
  @getCardClass:(index)->
    return Card.getClass(@cards[index])

  # 使用可能か
  @isUsable:(index)->
    # 存在しない
    return false unless @status[index]?
    # 使用可能状態でない
    return false if @status[index] isnt @STATUS_USABLE
    # そもそも置けない
    return false unless @getCardClass(index).isWorkable()
    true

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

  # 描画
  @redraw:->
    me = @getElement()

    me.html('')
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
    e = $('<div>').attr('data-index', index).addClass('private')

    # ヘッダ
    # [コスト]カード名
    costStr = if cardClass.isPublicOnly() then '' else '['+cost+']'
    header = $('<span>').addClass('private_header').html(costStr+cardClass.getName())

    # 画像
    img = cardClass.getImageObj().addClass('private_image')

    # フッタ
    # カテゴリ
    catStr = if cat? then '['+cat+']' else ''
    categorySpan = $('<span>').addClass('private_footer private_category').html(catStr)
    # 得点
    pointStr = if cardClass.isPublicOnly() then '' else '[$'+point+']'
    pointSpan = $('<span>').addClass('private_footer private_point').html(pointStr)

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
    e.attr('data-tooltip', balloonStr).darkTooltip()

    # 労働者により使用不可
    switch @status[index]
      when @STATUS_WORKED
        e.append $('<img>').attr('src', @IMG_WORKER).addClass('worker')
      when @STATUS_TIMER
        e.append $('<img>').attr('src', @IMG_TIMER).addClass('worker')

    # ダブルクリック時には使用する
    e.dblclick ->
      index = Number $(this).attr('data-index')
      Game.work 'private', index


    e.append header
    e.append img
    e.append categorySpan
    e.append pointSpan
    e

  # 法律事務所が存在するか（No.22）
  @isExistHouritu:->
    for cardNum in @cards
      return true if cardNum is 22
    false