class window.Game
  @objs : {}
  @isSetObj : false
  @isClickable : false
  # カードの選択待ち
  # false : 待ちではない
  # [kubun, index, isRightClick] : 区分、インデックス番号、右クリック有効
  @waitChoice : false

  @init : ->
    @setObj()
    obj.init() for name, obj of @objs
    @refresh()

  @refresh:->
    @objs.public.redraw()
    @objs.private.redraw()
    @objs.hand.redraw()
    @objs.budget.redraw()
    @objs.stock.redraw()
    @objs.unpaid.redraw()
    @objs.point.redraw()
    @objs.worker.redraw()

  @setObj : ->
    return if @isSetObj
    @isSetObj = true
    @objs.public   = PublicSpace
    @objs.private  = PrivateSpace
    @objs.hand     = HandSpace
    @objs.log      = LogSpace
    @objs.round    = RoundDeck
    @objs.deck     = Deck
    @objs.consumer = Consumer
    @objs.budget   = Budget
    @objs.stock    = Stock
    @objs.unpaid   = Unpaid
    @objs.point    = Point
    @objs.worker   = Worker
    @objs.ok       = ButtonOK
    @objs.cancel   = ButtonCANCEL

  @gameStart:->
    @isClickable = false

    @init()
    # 3枚デッキから引く
    @pullDeck 3
    # デッキの一番上に工場を乗せる
    @objs.deck.place 17
    # 4枚公共に置く
    @pullPublic 4

    @isClickable = true

  # ハンド選択
  @handClickLeft:(index)->
    # 選択待ちでなければならない
    return false if @waitChoice is false
    # 
    @objs.hand.clickLeft()
  @handClickRight:(index)->
    # 選択待ちでなければならない
    return false if @waitChoice is false
    # 右クリック可能でなければならない
    return false if @waitChoice[2] is false
    # 
    @objs.hand.clickRight()

  # 働かせる
  @work:(kubun, index)->
    # クリック不可
    return false unless @isClickable
    return false unless @isClickable
    # 置けない
    return false if kubun is "public" and not PublicSpace.isUsable index
    return false if kubun is "private" and not PrivateSpace.isUsable index
    # 労働者がいない
    return false if Worker.getActive() <= 0

    @isClickable = false

    # クラス
    spaceClass = if kubun is "public" then PublicSpace else PrivateSpace

    # 実行する
    cardClass = spaceClass.getCardClass index

    # 選択の必要があるか
    [leftReqNum, rightReqNum] = cardClass.requireCards()
    # ない
    if leftReqNum is 0 and rightReqNum is 0
      res = cardClass.use()
      # 正常終了しなかった
      if res isnt true
        alert res
        @isClickable = true
        return false
      # 正常終了
      @objs.worker.work() # 労働者を減らす
      spaceClass.setWorked index # 労働者を置く
      PublicSpace.disableLastest()  # 最新の職場を潰す
      @refresh()
      # 終わったら
      if @objs.worker.getActive() <= 0
        alert "労働者終わり"
      @isClickable = true


    # ある
    else
      @waitChoice = [kubun, index, cardClass.isRightClick()]
    return true

  # カードをデッキから手札に移動
  @pullDeck:(amount = 1)->
    @objs.hand.push @objs.deck.pull() for i in [0...amount]
    @objs.hand.redraw()

  # 消費財を引く
  @pullConsumer:(amount = 1)->
    @objs.hand.push @objs.consumer.pull() for i in [0...amount]
    @objs.hand.redraw()

  # 公共デッキから公共に移動
  @pullPublic:(amount = 1)->
    @objs.public.push @objs.round.pull() for i in [0...amount]
    @objs.public.redraw()

  # 労働者を増やす
  @addWorkerNum:(amount = 1)->
    @objs.worker.add() for i in [0...amount]
    @objs.worker.redraw()

  # 労働者を指定数まで増やす
  @addWorkerUntil:(amount)->
    @objs.worker.add() while @objs.worker.getTotal() < amount
    @objs.worker.redraw()

  # アクティブな労働者を増やす
  @addWorkerActiveNum:(amount = 1)->
    @objs.worker.add(true) for i in [0...amount]
    @objs.worker.redraw()

  # 得点の再計算・表示
  @getPoint:->
    point = 0

    # 所持金を加算
    point += @objs.stock.getAmount()
    # 建造物の合計価値を加算
    point += @objs.private.getPoint()

    point