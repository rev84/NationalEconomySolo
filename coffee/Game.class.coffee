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
  # ゲーム終了フラグ
  @isGameEnd : false
  # 焼畑フラグ
  @flagYakihata : false

  @init : ->
    @isClickable = false

    @setObj()
    obj.init() for name, obj of @objs
    @refresh()

    @waitChoice   = false
    @isHandTrash  = false
    @isSell       = false
    @isGameEnd    = false
    @flagYakihata = false
    @isClickable  = true

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

  # ゲーム開始
  @gameStart:->
    @isClickable = false

    @init()
    # 3枚デッキから引く
    @pullDeck 3
    # デッキの一番上に工場を乗せる
    @objs.deck.place 17
    # 4枚公共に置く
    @pullPublic 4

    @clickable()

  # ゲーム終了
  @gameEnd:->
    @isGameEnd = true
    @refresh()
    @logScore()

  # 最終スコアを出力
  @logScore:->
    # 終了スコア発表
    [
      stock
      buildPoint
      unpaid
      hourituNum
      hudousanNum
      buildNum
      noukyouNum
      consumerNum
      rousoNum
      workerNum
      railNum
      industryNum
      honsyaNum
      unworkNum
      point
    ] = @getPoint true
    unpaidPoint = unpaid*5
    hourituOnkei = if unpaid > hourituNum*5 then hourituNum*5*3 else unpaid*3
    hudousanPoint = hudousanNum * buildNum*3
    noukyouPoint = noukyouNum * consumerNum*3
    rousoPoint = rousoNum * consumerNum*6
    railPoint = railNum * industryNum*3
    honsyaPoint = honsyaNum * unworkNum*3

    logStr = """
    ゲーム終了　スコア：$#{point}
    <hr>
    資金　　　　　　　　　　　　　　　　　　　　 $#{stock}
    建物の価値　　　　　　　　　　　　　　　　　 $#{buildPoint}
    未払い賃金　　　　　　　　　　$#{unpaid}　×　3　=> -$#{unpaidPoint}
    法律事務所　　#{hourituNum}件　×　未払い　$#{unpaid}　×　3　=>　$#{hourituOnkei}
    不動産屋　　　#{hudousanNum}件　×　建物　 #{buildNum}件　×　3　=>　$#{hudousanPoint}
    農協　　　　　#{noukyouNum}件　×　消費財 #{consumerNum}枚　×　3　=>　$#{noukyouPoint}
    労働組合　　　#{rousoNum}件　×　労働者 #{workerNum}人　×　6　=>　$#{rousoPoint}
    鉄道　　　　　#{railNum}件　×　工業　 #{industryNum}件　×　3　=>　$#{railPoint}
    本社ビル　　　#{honsyaNum}件　×　非職場 #{unworkNum}件　×　3　=>　$#{honsyaPoint}
    <hr>
    <button id="start" onclick="Game.gameStart()">もう一度やる</button>
    """.replace /\n/g, '<br>'
    LogSpace.addWarn logStr

  # ラウンドの終了判定
  @roundEnd:->
    @isClickable = false
    LogSpace.removeAll()

    # 手札が規定枚数以上なら手札を捨てなくてはならない
    if HandSpace.isHandOver()
      max = HandSpace.getMax()
      LogSpace.addWarn '手札を'+max+'枚になるまで捨ててください'
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
      LogSpace.addWarn(message.replace /\n/g, '<br>')
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

    #alert alertStr
    LogSpace.addWarnInstant alertStr.replace(/\n/g, '<br>'), 5

    # 資金を減らす
    Stock.pull minusSalary
    # 家計を増やす
    Budget.push minusSalary - penalty
    # 未払いを増やす
    Unpaid.push penalty
    # ラウンドを進める
    RoundDeck.addRound()

    # ゲーム終了
    if RoundDeck.getRound() >= 10
      return @gameEnd()

    # ラウンドカードを置く
    @pullPublic()
    # 公共カード・所有カードを使用可能にする
    PublicSpace.resetStatus()
    PrivateSpace.resetStatus()
    # 労働者を回復
    Worker.wake()
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
    @isClickable = false

    spaceClass = @kubun2class(kubun)

    Worker.work() # 労働者を減らす
    # 焼畑フラグが立っていなければ労働者を置く
    if @flagYakihata
      @flagYakihata = false
    else
      spaceClass.setWorked index 
    PublicSpace.disableLastest()  # 最新の職場を潰す
    @refresh()
    # 終わったら
    if Worker.getActive() <= 0
      @roundEnd()
    else
      @clickable()

  # ハンドのクリック判定
  @handClickLeft:(index)->
    # ゲーム終了
    return false if @isGameEnd
    # 選択待ちでなければならない
    return false if @waitChoice is false
    # 
    HandSpace.clickLeft index
    HandSpace.redraw()

  @handClickRight:(index)->
    # ゲーム終了
    return false if @isGameEnd
    # 選択待ちでなければならない
    return false if @waitChoice is false
    # 右クリック可能でなければならない
    return false if @waitChoice[2] is false
    # 
    HandSpace.clickRight index
    HandSpace.redraw()

  @handDoubleClick:(index)->
    # ゲーム終了
    return false if @isGameEnd
    # 手札を捨てる時以外使わない
    return false unless @isHandTrash
    HandSpace.trash [index]
    HandSpace.redraw()
    @roundEnd()

  # ボタンを押した時
  @pushOK:->
    # ゲーム終了
    return false if @isGameEnd
    # 選択状態ではない
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

    # 解除処理
    HandSpace.selectReset()
    ButtonOK.disable()
    ButtonCANCEL.disable()

    # 使用する
    spaceClass = @kubun2class(kubun)
    cardClass = spaceClass.getCardClass cardIndex
    LogSpace.removeAll()

    res = cardClass.use(left, right)
    # 使えた
    if res is true
      @turnEnd(kubun, cardIndex)
    # 使えなかった
    else
      LogSpace.addFatalInstant res
      HandSpace.redraw()
      @clickable()

    res is true

  @pushCANCEL:->
    # ゲーム終了
    return false if @isGameEnd
    # 選択状態ではない
    return false if @waitChoice is false
    @waitChoice = false
    HandSpace.selectReset()
    HandSpace.redraw()
    ButtonOK.disable()
    ButtonCANCEL.disable()
    LogSpace.removeAll()
    @clickable()
    true

  # 働かせる
  @work:(kubun, index)->
    # ゲーム終了
    return false if @isGameEnd
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
      res = cardClass.use([], [], kubun, index)
      # 正常終了しなかった
      if res isnt true
        alert res
        @clickable()
        return false
      # 正常終了
      @turnEnd(kubun, index)

    # ある
    else
      # 選択待ちにする
      @waitChoice = [kubun, index, cardClass.isRightClick()]
      # 選択待ちメッセージがあれば表示する
      LogSpace.addWarn(cardClass.getSelectMessage().replace /\n/g, '<br>')
      # ボタンを押せるようにする
      ButtonOK.enable()
      ButtonCANCEL.enable()
    return true

  # カードをデッキから手札に移動
  @pullDeck:(amount = 1)->
    HandSpace.push Deck.pull() for i in [0...amount]
    HandSpace.redraw()

  # 消費財を引く
  @pullConsumer:(amount = 1)->
    HandSpace.push Consumer.pull() for i in [0...amount]
    HandSpace.redraw()

  # 公共デッキから公共に移動
  @pullPublic:(amount = 1)->
    PublicSpace.push @objs.round.pull() for i in [0...amount]
    PublicSpace.redraw()

  # 建物を売る
  @sellPrivate:(index)->
    # 売却不可
    return false unless PrivateSpace.getCardClass(index).isSellable()

    # 公共に移す
    deletedCardNum = @objs.private.pull index
    PublicSpace.push deletedCardNum
    # 資金を増やす
    Stock.push Card.getClass(deletedCardNum).getPrice()

    # ラウンド終了判定
    @roundEnd()

  # 建物を売らなければいけないか
  @isMustSell:->
    # TODO:焼畑は手放さなくてはならない前提

    # (1)給料が支払えない
    cantPaySalary = Stock.getAmount() - Worker.getTotal() * RoundDeck.getSalary() < 0
    # (2)売れる建物がある
    canSell = PrivateSpace.isExistSellable()

    cantPaySalary and canSell


  # 得点の再計算・表示
  # getDetail = true なら
  # [0] 所持金
  # [1] 建造物の価値
  # [2] 未払い賃金
  # [3] 法律事務所の数
  # [4] 不動産屋の数
  # [5] 所有する建物の数
  # [6] 農協の数
  # [7] 手札の消費財の数
  # [8] 労働組合の数
  # [9] 労働者の数
  # [10] 鉄道の数
  # [11] 所有する工業カテゴリの建物の数
  # [12] 本社ビルの数
  # [13] 所有する非職場カテゴリの建物の数
  # [14] 合計点
  @getPoint:(getDetail = false)->
    point = 0

    # 所持金*1 加点
    point += Stock.getAmount()

    # 建造物の合計価値*1 加点
    point += PrivateSpace.getPoint()

    # (未払い賃金-法律事務所の数*5)*3 > 0 減点
    unpaidNum = Unpaid.getAmount()
    unpaidNum -= 5*PrivateSpace.getAmountHouritu()
    unpaidNum = if unpaidNum < 0 then 0 else unpaidNum
    point -= unpaidNum*3

    # 不動産屋の数*所有する建物の数*3 加点
    point += PrivateSpace.getAmountHudousan()*PrivateSpace.getAmount()*3

    # 農協の数*手札の消費財の数*3 加点
    point += PrivateSpace.getAmountNoukyou()*HandSpace.getAmountConsumer()*3

    # 労働組合の数*労働者の数*6 加点
    point += PrivateSpace.getAmountRouso()*Worker.getTotal()*6

    # 鉄道の数*所有する工業カテゴリの建物の数*3 加点
    point += PrivateSpace.getAmountRail()*PrivateSpace.getAmountIndustry()*6

    # 本社ビルの数*所有する非職場カテゴリの建物の数*3 加点
    point += PrivateSpace.getAmountBuilding()*PrivateSpace.getAmountUnworkable()*6

    if getDetail
      return [
        Stock.getAmount()
        PrivateSpace.getPoint()
        Unpaid.getAmount()
        PrivateSpace.getAmountHouritu()
        PrivateSpace.getAmountHudousan()
        PrivateSpace.getAmount()
        PrivateSpace.getAmountNoukyou()
        HandSpace.getAmountConsumer()
        PrivateSpace.getAmountRouso()
        Worker.getTotal()
        PrivateSpace.getAmountRail()
        PrivateSpace.getAmountIndustry()
        PrivateSpace.getAmountBuilding()
        PrivateSpace.getAmountUnworkable()
        point
      ]
    else
      return point

  # 区分 -> クラス
  @kubun2class:(kubun)->
    return PublicSpace if kubun is "public"
    PrivateSpace