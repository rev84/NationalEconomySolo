class window.Game
  @objs : {}
  @isSetObj : false
  @isClickable : false
  # カードの選択待ち
  # false : 待ちではない
  # [kubun, index, isRightClick] : 区分、インデックス番号、右クリック有効
  @waitChoice : false
  # 手札捨て期間
  @isHandTrash : false
  # 建物売り期間
  @isSell : false

  @init : ->
    @isClickable = false

    @setObj()
    obj.init() for name, obj of @objs
    @refresh()

    @waitChoice  = false
    @isHandTrash = false
    @isSell      = false
    @isClickable = true

  @refresh:->
    @objs.public.redraw()
    @objs.private.redraw()
    @objs.hand.redraw()
    @objs.budget.redraw()
    @objs.stock.redraw()
    @objs.unpaid.redraw()
    @objs.point.redraw()
    @objs.worker.redraw()
    @objs.round.redraw()

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


  # ラウンドの終了判定
  @roundEnd:->
    @objs.log.hide()

    # 手札が規定枚数以上なら手札を捨てなくてはならない
    if @objs.hand.isHandOver()
      max = @objs.hand.getMax()
      @objs.log.show '手札を'+max+'枚になるまで捨ててください'
      @isHandTrash = true
      return
    @isHandTrash = false

    if @isMustSell()
      # いくら足りないのか計算
      rest = @objs.worker.getTotal() * @objs.round.getSalary() - @objs.stock.getAmount()
      message = """
                給料が払えるようになるか、なくなるまで建物を売ってください
                不足額：$#{rest}
                """
      @objs.log.show message.replace /\n/g, '<br>'
      @isSell = true
      return
    @isSell = false

    @settle()

  # ラウンド終了精算
  @settle:->
    # 給料
    minusSalary = @objs.worker.getTotal() * @objs.round.getSalary()
    # 不足
    penalty = minusSalary - @objs.stock.getAmount()
    penalty = if penalty > 0 then penalty else 0

    alertStr = "ラウンド終了"
    alertStr += "\n\n"
    alertStr += "給料 $"+minusSalary+" を支払います\n"
    alertStr += "支払えなかった $"+penalty+" が未払いになります" if penalty isnt 0

    alert alertStr

    # 資金を減らす
    @objs.stock.pull minusSalary
    # 家計を増やす
    @objs.budget.push minusSalary - penalty
    # 未払いを増やす
    @objs.unpaid.push penalty
    # ラウンドを進める
    @objs.round.addRound()
    # ラウンドカードを置く
    @pullPublic()
    # 公共カード・所有カードを使用可能にする
    @objs.public.resetStatus()
    @objs.private.resetStatus()
    # 労働者を開腹
    @objs.worker.wake()
    # 再描画
    @refresh()

    @clickable()

  # プレイ続行状態にする
  @clickable:->
    @waitChoice  = false
    @isHandTrash = false
    @isSell      = false
    @isClickable = true

  # ターンの終了処理（建物）
  @turnEnd:(kubun, index)->
    spaceClass = @kubun2class(kubun)

    @objs.worker.work() # 労働者を減らす
    spaceClass.setWorked index # 労働者を置く
    PublicSpace.disableLastest()  # 最新の職場を潰す
    @refresh()
    # 終わったら
    if @objs.worker.getActive() <= 0
      @roundEnd()
    else
      @clickable()

  # ハンドのクリック判定
  @handClickLeft:(index)->
    # 選択待ちでなければならない
    return false if @waitChoice is false
    # 
    @objs.hand.clickLeft index
    @objs.hand.redraw()

  @handClickRight:(index)->
    # 選択待ちでなければならない
    return false if @waitChoice is false
    # 右クリック可能でなければならない
    return false if @waitChoice[2] is false
    # 
    @objs.hand.clickRight index
    @objs.hand.redraw()

  @handDoubleClick:(index)->
    # 手札を捨てる時以外使わない
    return false unless @isHandTrash
    @objs.hand.trash [index]
    @objs.hand.redraw()
    @roundEnd()

  # ボタンを押した時
  @pushOK:->
    return false if @waitChoice is false
    # 選択状態解除
    [kubun, cardIndex, _] = @waitChoice
    @waitChoice = false
    # ハンドのリストを作成
    left = []
    right = []
    for index in [0...@objs.hand.getAmount()]
      left.push index if @objs.hand.getSelect(index) is @objs.hand.SELECT_LEFT
      right.push index if @objs.hand.getSelect(index) is @objs.hand.SELECT_RIGHT

    # 使用する
    spaceClass = @kubun2class(kubun)
    cardClass = spaceClass.getCardClass cardIndex
    res = cardClass.use(left, right)
    # 使えた
    if res is true
      @objs.log.hide()
    # 使えなかった
    else
      @objs.log.show res
      @objs.log.fadeout 3

    @objs.hand.selectReset()
    @objs.ok.disable()
    @objs.cancel.disable()
    # 成功時
    if res is true
      @turnEnd(kubun, cardIndex)
    # 失敗時
    else
      @objs.hand.selectReset()
      @objs.hand.redraw()
      @objs.ok.disable()
      @objs.cancel.disable()
      @clickable()
    res is true

  @pushCANCEL:->
    return false if @waitChoice is false
    @waitChoice = false
    @objs.hand.selectReset()
    @objs.hand.redraw()
    @objs.ok.disable()
    @objs.cancel.disable()
    @objs.log.hide()
    @clickable()
    true

  # 働かせる
  @work:(kubun, index)->
    # クリック不可
    return false unless @isClickable
    # 置けない
    return false unless @kubun2class(kubun).isUsable index
    # 労働者がいない
    return false if Worker.getActive() <= 0

    @isClickable = false

    # クラス
    spaceClass = @kubun2class(kubun)

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
      @turnEnd(kubun, index)
      @isClickable = true

    # ある
    else
      # 選択待ちにする
      @waitChoice = [kubun, index, cardClass.isRightClick()]
      # 選択待ちメッセージがあれば表示する
      @objs.log.show cardClass.getSelectMessage().replace /\n/g, '<br>'
      # ボタンを押せるようにする
      @objs.ok.enable()
      @objs.cancel.enable()
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

  # 建物を売る
  @sellPrivate:(index)->
    # 売却不可
    return false unless @objs.private.getCardClass(index).isSellable()

    # 公共に移す
    deletedCardNum = @objs.private.pull index
    @objs.public.push deletedCardNum
    # 資金を増やす
    @objs.stock.push Card.getClass(deletedCardNum).getPrice()

    # ラウンド終了判定
    @roundEnd()

  # 建物を売らなければいけないか
  @isMustSell:->
    # TODO:焼畑は手放さなくてはならない前提

    # (1)給料が支払えない
    cantPaySalary = @objs.stock.getAmount() - @objs.worker.getTotal() * @objs.round.getSalary() < 0
    # (2)売れる建物がある
    canSell = @objs.private.isExistSellable()

    cantPaySalary and canSell


  # 得点の再計算・表示
  @getPoint:->
    point = 0

    # 所持金を加算
    point += @objs.stock.getAmount()
    # 建造物の合計価値を加算
    point += @objs.private.getPoint()
    # 未払いを引く
    unpaidNum = @objs.unpaid.getAmount()
    if @objs.private.isExistHouritu()
      unpaidNum -= 5
    unpaidNum = if unpaidNum < 0 then 0 else unpaidNum
    point -= unpaidNum

    point

  # 区分 -> クラス
  @kubun2class:(kubun)->
    return PublicSpace if kubun is "public"
    PrivateSpace