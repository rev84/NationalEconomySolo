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
  # 設計事務所フラグ
  @flagSekkei : false

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
    @flagSekkei   = false
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
    unpaidPoint = unpaid*3
    hourituOnkei = if unpaid > hourituNum*5 then hourituNum*5*3 else unpaid*3
    hudousanPoint = hudousanNum * buildNum*3
    noukyouPoint = noukyouNum * consumerNum*3
    rousoPoint = rousoNum * workerNum*6
    railPoint = railNum * industryNum*8
    honsyaPoint = honsyaNum * unworkNum*6

    logStr = """
    ゲーム終了　スコア：$#{point}
    <hr>
    <table class="score">
    <tr>
      <td>資金</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>$#{stock}</td>
    </tr>
    <tr>
      <td>建物の価値</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>$#{buildPoint}</td>
    </tr>
    <tr>
      <td>未払い賃金</td>
      <td></td>
      <td></td>
      <td></td>
      <td>-$#{unpaid}</td>
      <td>×</td>
      <td>3</td>
      <td>=></td>
      <td>-$#{unpaidPoint}</td>
    </tr>
    <tr>
      <td>法律事務所</td>
      <td>#{hourituNum}件</td>
      <td>×</td>
      <td></td>
      <td>$5</td>
      <td>×</td>
      <td>3</td>
      <td>=></td>
      <td>$#{hourituOnkei}</td>
    </tr>
    <tr>
      <td>不動産屋</td>
      <td>#{hudousanNum}件</td>
      <td>×</td>
      <td>建物</td>
      <td>#{buildNum}件</td>
      <td>×</td>
      <td>3</td>
      <td>=></td>
      <td>$#{hudousanPoint}</td>
    </tr>
    <tr>
      <td>農協</td>
      <td>#{noukyouNum}件</td>
      <td>×</td>
      <td>消費財</td>
      <td>#{consumerNum}枚</td>
      <td>×</td>
      <td>3</td>
      <td>=></td>
      <td>$#{noukyouPoint}</td>
    </tr>
    <tr>
      <td>労働組合</td>
      <td>#{rousoNum}件</td>
      <td>×</td>
      <td>労働者</td>
      <td>#{workerNum}人</td>
      <td>×</td>
      <td>6</td>
      <td>=></td>
      <td>$#{rousoPoint}</td>
    </tr>
    <tr>
      <td>鉄道</td>
      <td>#{railNum}件</td>
      <td>×</td>
      <td>工業</td>
      <td>#{industryNum}件</td>
      <td>×</td>
      <td>8</td>
      <td>=></td>
      <td>$#{railPoint}</td>
    </tr>
    <tr>
      <td>本社ビル</td>
      <td>#{honsyaNum}件</td>
      <td>×</td>
      <td>施設</td>
      <td>#{unworkNum}件</td>
      <td>×</td>
      <td>6</td>
      <td>=></td>
      <td>$#{honsyaPoint}</td>
    </tr>
    </table>
    <hr>
    <button id="start" onclick="Game.gameStart()">もう一度やる</button>
    """
    LogSpace.addInfo logStr

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
      rest = Worker.getTotal() * RoundDeck.getSalary() - Stock.getAmount() - PrivateSpace.getTotalSell()
      message = """
                給料が払えるようになるか、なくなるまで建物を売ってください
                不足額：$#{rest}
                """
      LogSpace.addWarn(message.replace /\n/g, '<br>')
      @isSell = true
      PrivateSpace.cache()
      return

    if PrivateSpace.sellingBox.length > 0
      if @canSell()
        @sellPrivate()
        return
      else
        message = '売る必要のない建物が含まれています。'
        LogSpace.addFatalInstant(message)
        PrivateSpace.rollback()
        PrivateSpace.sellingBox = []
        @roundEnd()
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
    LogSpace.addInfoInstant alertStr.replace(/\n/g, '<br>'), 5

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
    backupWaitChoice = @waitChoice.concat()
    [kubun, cardIndex, _] = @waitChoice
    @waitChoice = false
    # ハンドのリストを作成
    left = []
    right = []
    for index in [0...@objs.hand.getAmount()]
      left.push index if HandSpace.getSelect(index) is HandSpace.SELECT_LEFT
      right.push index if HandSpace.getSelect(index) is HandSpace.SELECT_RIGHT

    # 解除処理
    HandSpace.selectReset()
    ButtonOK.disable()
    ButtonCANCEL.disable()

    # 使用する
    spaceClass = @kubun2class(kubun)
    cardClass = spaceClass.getCardClass cardIndex
    LogSpace.removeAll() unless @flagSekkei

    res = cardClass.use(left, right)
    # 使えた
    if res is true
      LogSpace.removeAll()
      @turnEnd(kubun, cardIndex)
    # 使えなかった
    else
      LogSpace.addFatalInstant res
      HandSpace.redraw()
      # 設計事務所は後戻りできない
      if @flagSekkei
        ButtonOK.enable()
        @waitChoice = backupWaitChoice
      else
        @clickable()

    res is true

  @pushCANCEL:->
    # ゲーム終了
    return false if @isGameEnd
    # 選択状態ではない
    return false if @waitChoice is false
    # 設計事務所はキャンセルできない
    return false if @flagSekkei isnt false
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

    # 事前実行
    cardClass.preUse() if cardClass.preUse isnt false

    # 選択の必要があるか
    [leftReqNum, rightReqNum] = cardClass.requireCards()
    # ない
    if leftReqNum is 0 and rightReqNum is 0
      res = cardClass.use([], [], kubun, index)
      # 正常終了しなかった
      if res isnt true
        LogSpace.addFatalInstant res
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
      ButtonCANCEL.enable() unless @flagSekkei
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

  # 建物を売る候補に入れる
  @pushSellingBox:(index)->
    # 売却不可
    return false unless PrivateSpace.getCardClass(index).isSellable()
    PrivateSpace.sellingBox.push(PrivateSpace.pull index)
    PrivateSpace.redraw()
    # ラウンド終了判定
    @roundEnd()

  # 建物を売る
  @sellPrivate:->
    for cardNum in PrivateSpace.sellingBox
      # sellingBoxの中身を公共に移す
      PublicSpace.push cardNum
      # 資金を増やす
      Stock.push(Card.getClass(cardNum).getPrice())

    PrivateSpace.sellingBox = []
    PrivateSpace.uncache()
    PublicSpace.redraw()

    # ラウンド終了判定
    @roundEnd()

  # 建物を売らなければいけないか
  @isMustSell:->
    # TODO:焼畑は手放さなくてはならない前提

    # (1)給料が支払えない
    cantPaySalary = Stock.getAmount() + PrivateSpace.getTotalSell() < Worker.getTotal() * RoundDeck.getSalary()
    # (2)売れる建物がある
    canSell = PrivateSpace.isExistSellable()

    cantPaySalary and canSell

  # 選択した建物を実際に売れるかどうか
  @canSell:->
    totalSell = PrivateSpace.getTotalSell()
    minCost = null
    for cardNum in PrivateSpace.sellingBox
      cost = Card.getClass(cardNum).getPrice()
      if (minCost is null || cost < minCost)
        minCost = cost
    # 候補を全て売却した後の資金が、候補の中で最も安い建物の価格より低い。
    Stock.getAmount() + totalSell - Worker.getTotal() * RoundDeck.getSalary() < minCost


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
  # [13] 所有する施設カテゴリの建物の数
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

    # 鉄道の数*所有する工業カテゴリの建物の数*8 加点
    point += PrivateSpace.getAmountRail()*PrivateSpace.getAmountIndustry()*8

    # 本社ビルの数*所有する施設カテゴリの建物の数*6 加点
    point += PrivateSpace.getAmountBuilding()*PrivateSpace.getAmountInstitution()*6

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
        PrivateSpace.getAmountInstitution()
        point
      ]
    else
      return point

  # 区分 -> クラス
  @kubun2class:(kubun)->
    return PublicSpace if kubun is "public"
    PrivateSpace
