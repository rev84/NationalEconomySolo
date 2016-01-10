class PrivateSpace extends CardSpace
  @DIV_ID = "private"

  # バルーンにつけるクラス
  @BALLOON_CLASS_NAME = 'balloon_private'

  # 建物の状態の定数
  @STATUS_USABLE = 0
  @STATUS_WORKED = 1
  @STATUS_SELLING = 2

  # 建物の状態
  @status:[]

  # 売却予定の建物を入れる箱。カード番号を格納する。
  @sellingBox:[]

  # 売却不可の時のロールバックに使うキャッシュ
  @cacheObj: {}

  @init:->
    super()
    @status = []
    @sellingBox = []
    @cacheObj = {}

  # すべて使用可能にする
  @resetStatus:->
    @status = []
    @status[index] = @STATUS_USABLE for index in [0...@cards.length]

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

  # ダブルクリック時アクションの上書き
  @cardDoubleClickAction:(elem) ->
    # 通常時は労働者を派遣
    if Game.isClickable
      index = Number $(elem).attr('data-index')
      Game.work 'private', index
    # 建物を売る
    else if Game.isSell
      index = Number $(elem).attr('data-index')
      Game.pushSellingBox index

  # 労働者により使用不可
  @additionalCardAction:(elem, index)->
    if @status[index] is @STATUS_WORKED
      elem.addClass('card_used')
      elem.append $('<img>').attr('src', @IMG_WORKER).addClass('card_worker')

  # 売れる建物があるか
  @isExistSellable:->
    # TODO:焼畑は売れる建物に含まれる前提
    for index in [0...@cards.length]
      cardClass = @getCardClass index
      return true if cardClass.isSellable()
    false

  # 売却候補の総額
  @getTotalSell:->
    result = 0
    for cardNum in @sellingBox
      result += Card.getClass(cardNum).getPrice()
    return result

  # キャッシュが空ならキャッシュする
  @cache:->
    if Object.keys(@cacheObj).length == 0
      @cacheObj = {
        cards: @cards.concat(),
        status: @status.concat()
      }
    return

  @uncache:->
    @cacheObj = {}
    return

  # キャッシュの状態に戻る。
  @rollback:->
    @cards = @cacheObj['cards']
    @status = @cacheObj['status']
    @uncache()
    @redraw()
    return

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
