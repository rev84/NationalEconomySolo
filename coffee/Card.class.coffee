class Card
  # 鉱山のカードNo
  @CARD_NUM_KOUZAN   = 2
  # 焼畑のカードNo
  @CARD_NUM_YAKIHATA = 15
  # 倉庫のカードNo
  @CARD_NUM_SOUKO   = 20
  # 法律事務所のカードNo
  @CARD_NUM_HOURITU = 22
  # 社宅のカードNo
  @CARD_NUM_SYATAKU = 21
  # 不動産屋のカードNo
  @CARD_NUM_HUDOUSAN = 26
  # 農協のカードNo
  @CARD_NUM_NOUKYOU = 27
  # 労働組合のカードNo
  @CARD_NUM_ROUSO = 31
  # 鉄道のカードNo
  @CARD_NUM_RAIL = 35
  # 本社ビルのカードNo
  @CARD_NUM_BUILDING = 36
  # 消費財のカードNo
  @CARD_NUM_CONSUMER = 99

  @getClass = (classNum)->
    try
      res = eval("Card"+classNum)
    catch
      return false
    return false unless res?
    res

class CardBase
  # 名称
  @NAME = null
  # カテゴリ
  @CATEGORY = null
  # 説明文
  @DESCRIPTION = null
  # コスト
  @COST = 0
  # 得点
  @PRICE = 0

  # 選択時に"+DeviceChecker.rightClickMessage()+"可能か
  @isRightClick:->
    [l, r] = @requireCards()
    r > 0

  # 手札からカードを何枚選ぶ必要性があるか
  @requireCards:->
    [0,0]

  # 選択待ちの時に表示するメッセージ
  @getSelectMessage:->
    false

  # 使用前の下準備がある場合
  @preUse:false

  # 労働者を派遣した時の挙動
  @use:(leftIndexs = [], rightIndexs = [])->
    # 数のバリデーション
    [leftReqNum, rightReqNum] = @requireCards()
    return false unless leftIndexs.length is leftReqNum and rightIndexs.length is rightReqNum
    true

  # カード名を取得
  @getName:->
    @NAME

  # カード名を取得
  @getCategory:->
    @CATEGORY

  # カードNoを取得
  @getNumber:->
    res = @name.match /^Card(\d+)$/
    return Number res[1] if res?
    false

  # 説明文（HTML）を取得
  @getDescription:->
    @DESCRIPTION

  # 公共カテゴリであるか
  @isPublicOnly:->
    @CATEGORY is '公共'

  # 建設できるカテゴリか
  @isBuildable:->
    @CATEGORY isnt '消費財'

  # 農業カテゴリであるか
  @isFarming:->
    @CATEGORY is '農業'

  # 工業カテゴリであるか
  @isIndustry:->
    @CATEGORY is '工業'

  # 施設カテゴリであるか
  @isInstitution:->
    @CATEGORY is '施設'

  # 消費財であるか
  @isConsumer:->
    @CATEGORY is '消費財'

  # 労働者を置けるか
  @isWorkable:->
    return false if @isConsumer()
    return false if @isInstitution()
    true

  # 売却できるか
  @isSellable:->
    @isWorkable()

  # コストを取得
  @getCost:->
    @COST

  # 売った時の収入を取得
  @getPrice:->
    @PRICE

  # 得点を取得
  @getPoint:->
    @PRICE*2

  # カードの画像パスを取得
  @getImagePath:->
    './img/card/'+@getNumber()+'.jpg'

  # カードのimgのjQueryオブジェクトを取得
  @getImageObj:->
    $('<img>').attr 'src', @getImagePath()

# No.01 採石場 一人用プレイの場合は使用しない

# No.02 鉱山
class Card2 extends CardBase
  @NAME        = "鉱山"
  @CATEGORY    = "公共"
  @DESCRIPTION = "カードを1枚引く\n何度でも使える"

  @use:->
    Game.pullDeck()
    true

# No.03 学校
class Card3 extends CardBase
  @NAME        = "学校"
  @CATEGORY    = "公共"
  @DESCRIPTION = "労働者を1人増やす"

  @use:->
    return "労働者が上限に達しています" if Worker.isLimit()
    Worker.add()
    true

# No.04 大工
class Card4 extends CardBase
  @NAME        = "大工"
  @CATEGORY    = "公共"
  @DESCRIPTION = "建物を1つ作る"

  @requireCards:->
    [1,1]

  @getSelectMessage:->
    "選択してください\n"+DeviceChecker.leftClickMessage()+"：建物1枚\n"+DeviceChecker.rightClickMessage()+"：捨札（建物コストの枚数）"

  @use:(leftIndexs, rightIndexs)->
    #return "指定カードが足りません" unless super()

    # 建物は1枚でなければならない
    return "建物1枚を選択しなければなりません" if leftIndexs.length isnt 1

    buildCardIndex = leftIndexs[0]
    buildCardNum = HandSpace.getCardNum buildCardIndex
    cardClass    = HandSpace.getCardClass buildCardIndex
    cost = cardClass.getCost()

    # 建物は消費財であってはならない
    return "消費財は建設できません" unless cardClass.isBuildable()
    # 捨札は、コストと同一でなければならない
    return "捨札が建設コストと一致していません" if cost isnt rightIndexs.length

    # 建物を建てる
    PrivateSpace.push buildCardNum
    # 捨札を墓地に、建物を手札から消す
    HandSpace.trash rightIndexs, leftIndexs

    true

# No.05 露店
class Card5 extends CardBase
  @NAME        = "露店"
  @CATEGORY    = "公共"
  @DESCRIPTION = "手札を1枚捨てる\n家計から$6を得る"

  @requireCards:->
    [1,0]

  @getSelectMessage:->
    "選択してください\n"+DeviceChecker.leftClickMessage()+"：捨札1枚"

  @use:(leftIndexs)->
    return "捨札1枚が選択されていません" unless super
    return '家計が$6未満なので回収できません' if Budget.getAmount() < 6

    # 資金を増やす
    Stock.push 6
    # 家計を減らす
    Budget.pull 6
    # 捨札を墓地に
    HandSpace.trash leftIndexs

    true

# No.06 市場
class Card6 extends CardBase
  @NAME        = "市場"
  @CATEGORY    = "公共"
  @DESCRIPTION = "手札を2枚捨てる\n家計から$12を得る"

  @requireCards:->
    [2,0]

  @getSelectMessage:->
    "選択してください\n"+DeviceChecker.leftClickMessage()+"：捨札2枚"

  @use:(leftIndexs)->
    return "捨札2枚が選択されていません" unless super
    return '家計が$12未満なので回収できません' if Budget.getAmount() < 12

    # 資金を増やす
    Stock.push 12
    # 家計を減らす
    Budget.pull 12
    # 捨札を捨てる
    HandSpace.trash leftIndexs

    true


# No.07 高等学校
class Card7 extends CardBase
  @NAME        = "高等学校"
  @CATEGORY    = "公共"
  @DESCRIPTION = "労働者を4人に増やす"

  @use:->
    return "既に労働者が4人以上います" if Worker.getTotal() >= 4

    # 労働者を4人に
    Worker.setMax 4

    true

# No.08 スーパーマーケット
class Card8 extends CardBase
  @NAME        = "スーパーマーケット"
  @CATEGORY    = "公共"
  @DESCRIPTION = "手札を3枚捨てる\n家計から$18を得る"

  @requireCards:->
    [3,0]

  @getSelectMessage:->
    "選択してください\n"+DeviceChecker.leftClickMessage()+"：捨札3枚"

  @use:(leftIndexs)->
    return "捨札3枚が選択されていません" unless super
    return '家計が$18未満なので回収できません' if Budget.getAmount() < 18

    # 資金を増やす
    Stock.push 18
    # 家計を減らす
    Budget.pull 18
    # 捨札を捨てる
    HandSpace.trash leftIndexs

    true


# No.09 大学
class Card9 extends CardBase
  @NAME        = "大学"
  @CATEGORY    = "公共"
  @DESCRIPTION = "労働者を5人に増やす"

  @use:(leftIndexs, rightIndexs)->
    return "既に労働者が5人以上います" if Worker.getTotal() >= 5

    # 労働者を4人に
    Worker.setMax 5

    true

# No.10 百貨店
class Card10 extends CardBase
  @NAME        = "百貨店"
  @CATEGORY    = "公共"
  @DESCRIPTION = "手札を4枚捨てる\n家計から$24を得る"

  @requireCards:->
    [4,0]

  @getSelectMessage:->
    "選択してください\n"+DeviceChecker.leftClickMessage()+"：捨札4枚"

  @use:(leftIndexs)->
    return "捨札4枚が選択されていません" unless super
    return '家計が$24未満なので回収できません' if Budget.getAmount() < 24

    # 資金を増やす
    Stock.push 24
    # 家計を減らす
    Budget.pull 24
    # 捨札を捨てる
    HandSpace.trash leftIndexs

    true

# No.11 専門学校
class Card11 extends CardBase
  @NAME        = "専門学校"
  @CATEGORY    = "公共"
  @DESCRIPTION = "労働者を1人増やす\nこのラウンドからすぐ働ける"

  @use:->
    return "労働者が上限に達しています" if Worker.isLimit()
    Worker.add(true)
    true

# No.12 万博
class Card12 extends CardBase
  @NAME        = "万博"
  @CATEGORY    = "公共"
  @DESCRIPTION = "手札を5枚捨てる\n家計から$30を得る"

  @requireCards:->
    [5,0]

  @getSelectMessage:->
    "選択してください\n"+DeviceChecker.leftClickMessage()+"：捨札5枚"

  @use:(leftIndexs)->
    return "捨札5枚が選択されていません" unless super
    return '家計が$30未満なので回収できません' if Budget.getAmount() < 30

    # 資金を増やす
    Stock.push 30
    # 家計を減らす
    Budget.pull 30
    # 捨札を捨てる
    HandSpace.trash leftIndexs

    true

# No.13 農場
class Card13 extends CardBase
  @NAME        = "農場"
  @CATEGORY    = "農業"
  @DESCRIPTION = "消費財を2枚引く"
  @COST        = 1
  @PRICE       = 3

  @use:->
    # 消費財を2枚引く
    Game.pullConsumer 2

    true

# No.14 設計事務所
class Card14 extends CardBase
  @NAME        = "設計事務所"
  @DESCRIPTION = "カードを5枚めくり公開する\nうち1枚を引いて残りを捨てる"
  @COST        = 1
  @PRICE       = 4

  @preUse:->
    # 手札を引く
    Game.pullDeck 5
    # フラグを立てる
    Game.flagSekkei = true

  @requireCards:->
    [4,0]

  @getSelectMessage:->
    "選択してください\n"+DeviceChecker.leftClickMessage()+"：捨札4枚\n（最後に引いた5枚の中から）"

  @use:(leftIndexs)->
    return "捨札4枚が選択されていません" unless super

    count = 0
    for index in [HandSpace.getAmount()-5...HandSpace.getAmount()]
      count++ if leftIndexs.in_array index

    return "最後に引いた5枚のうちの4枚が選択されていません" if count isnt 4

    # 捨札4枚を捨てる
    HandSpace.trash leftIndexs
    # フラグを削除
    Game.flagSekkei = false
    true

# No.15 焼畑
class Card15 extends CardBase
  @NAME        = "焼畑"
  @CATEGORY    = "農業"
  @DESCRIPTION = "消費財を5枚引く\n焼畑は消滅する\n売却不可"
  @COST        = 1
  @PRICE       = 0

  # 例外的に売却できない
  @isSellable:->
    false

  @use:(leftIndexs, rightIndexs, kubun, index)->
    # 消費財を5枚引く
    Game.pullConsumer 5
    # 消滅する
    Game.flagYakihata = true
    space = Game.kubun2class kubun
    space.pull index

    # 焼畑を捨札にする
    Deck.trash @CARD_NUM_YAKIHATA

    true


# No.16 珈琲店
class Card16 extends CardBase
  @NAME        = "珈琲店"
  @DESCRIPTION = "家計から$5を得る"
  @COST        = 1
  @PRICE       = 4

  @use:->
    return '家計が$5未満なので回収できません' if Budget.getAmount() < 5

    # 資金を増やす
    Stock.push 5
    # 家計を減らす
    Budget.pull 5

    true

# No.17 工場
class Card17 extends CardBase
  @NAME        = "工場"
  @CATEGORY    = "工業"
  @DESCRIPTION = "手札を2枚捨てる\nカードを4枚引く"
  @COST        = 2
  @PRICE       = 6

  @requireCards:->
    [2,0]

  @getSelectMessage:->
    "選択してください\n"+DeviceChecker.leftClickMessage()+"：捨札2枚"

  @use:(leftIndexs)->
    return "捨札2枚が選択されていません" unless super

    # 捨札2枚を捨てる
    HandSpace.trash leftIndexs
    # カードを4枚引く
    Game.pullDeck 4

    true

# No.18 建設会社
class Card18 extends CardBase
  @NAME        = "建設会社"
  @DESCRIPTION = "1少ないコストで建物を1つ作る\n"
  @COST        = 2
  @PRICE       = 5
  @requireCards:->
    [1,1]

  @getSelectMessage:->
    "選択してください\n"+DeviceChecker.leftClickMessage()+"：建物1枚\n"+DeviceChecker.rightClickMessage()+"：捨札（建設コスト-1の枚数）"

  @use:(leftIndexs, rightIndexs)->
    #return "指定カードが足りません" unless super()

    # 建物は1枚でなければならない
    return "建物を1枚選択しなければなりません" if leftIndexs.length isnt 1

    buildCardIndex = leftIndexs[0]
    buildCardNum = HandSpace.getCardNum buildCardIndex
    cardClass    = HandSpace.getCardClass buildCardIndex
    cost = cardClass.getCost()

    # 建物は消費財であってはならない
    return "消費財は建設できません" unless cardClass.isBuildable()

    # 捨札は、コスト-1と同一でなければならない
    return "捨札が建設コストと一致していません" if cost-1 isnt rightIndexs.length

    # 建物を建てる
    PrivateSpace.push buildCardNum
    # 建物と捨札を捨てる
    HandSpace.trash rightIndexs, leftIndexs

    true


# No.19 果樹園
class Card19 extends CardBase
  @NAME        = "果樹園"
  @CATEGORY    = "農業"
  @DESCRIPTION = "手札が4枚になるまで消費財を引く"
  @COST        = 2
  @PRICE       = 5

  @use:->
    return "手札が4枚以上なので置けません" if HandSpace.getAmount() >= 4

    Game.pullConsumer(4-HandSpace.getAmount())

    true


# No.20 倉庫
class Card20 extends CardBase
  @NAME        = "倉庫"
  @CATEGORY    = "施設"
  @DESCRIPTION = "手札上限+4\n（パッシブ）\n売却不可"
  @COST        = 2
  @PRICE       = 5

# No.21 社宅
class Card21 extends CardBase
  @NAME        = "社宅"
  @CATEGORY    = "施設"
  @DESCRIPTION = "労働者上限+1\n（パッシブ）\n売却不可"
  @COST        = 2
  @PRICE       = 4

# No.22 法律事務所
class Card22 extends CardBase
  @NAME        = "法律事務所"
  @CATEGORY    = "施設"
  @DESCRIPTION = "終了時：負債から5枚まで免除する\n売却不可"
  @COST        = 2
  @PRICE       = 4

# No.23 大農園
class Card23 extends CardBase
  @NAME        = "大農園"
  @CATEGORY    = "農業"
  @DESCRIPTION = "消費財を3枚引く"
  @COST        = 3
  @PRICE       = 6

  @use:->
    # 消費財を3枚引く
    Game.pullConsumer 3

    true

# No.24 レストラン
class Card24 extends CardBase
  @NAME        = "レストラン"
  @DESCRIPTION = "手札を1枚捨てる\n家計から$15を得る"
  @COST        = 3
  @PRICE       = 8

  @requireCards:->
    [1,0]

  @getSelectMessage:->
    "選択してください\n"+DeviceChecker.leftClickMessage()+"：捨札1枚"

  @use:(leftIndexs)->
    return "捨札1枚が選択されていません" unless super
    return '家計が$15未満なので回収できません' if Budget.getAmount() < 15

    # 資金を増やす
    Stock.push 15
    # 家計を減らす
    Budget.pull 15
    # 捨札を捨てる
    HandSpace.trash leftIndexs

    true

# No.25 開拓民
class Card25 extends CardBase
  @NAME        = "開拓民"
  @DESCRIPTION = "手札の農業カテゴリの建物を1つコスト0で作る"
  @COST        = 3
  @PRICE       = 7

  @requireCards:->
    [1,0]

  @getSelectMessage:->
    "選択してください\n"+DeviceChecker.leftClickMessage()+"：農業カテゴリの建物1枚"

  @use:(leftIndexs)->
    #return "指定カードが足りません" unless super()

    # 建物は1枚でなければならない
    return "建物を1枚選択しなければなりません" if leftIndexs.length isnt 1

    buildCardIndex = leftIndexs[0]
    buildCardNum = HandSpace.getCardNum buildCardIndex
    cardClass    = HandSpace.getCardClass buildCardIndex

    # 建物は農業カテゴリでなければならない
    return "建物が農業カテゴリではありません" unless cardClass.isFarming()

    # 建物を建てる
    PrivateSpace.push buildCardNum
    # 建物と捨札を捨てる
    HandSpace.trash [], leftIndexs

    true

# No.26 不動産屋
class Card26 extends CardBase
  @NAME        = "不動産屋"
  @CATEGORY    = "施設"
  @DESCRIPTION = "終了時：所有する建物1つにつき+3点\n（この建物を含む）\n売却不可"
  @COST        = 3
  @PRICE       = 5

# No.27 農協
class Card27 extends CardBase
  @NAME        = "農協"
  @CATEGORY    = "施設"
  @DESCRIPTION = "終了時：手札の消費財1枚につき+3点\n売却不可"
  @COST        = 3
  @PRICE       = 6

# No.28 製鉄所
class Card28 extends CardBase
  @NAME        = "製鉄所"
  @CATEGORY    = "工業"
  @DESCRIPTION = "カードを3枚引く"
  @COST        = 4
  @PRICE       = 10

  @use:->
    Game.pullDeck 3
    true

# No.29 ゼネコン
class Card29 extends CardBase
  @NAME        = "ゼネコン"
  @DESCRIPTION = "建物を1つ作る\nカードを2枚引く"
  @COST        = 4
  @PRICE       = 9

  @requireCards:->
    [1,1]

  @getSelectMessage:->
    "選択してください\n"+DeviceChecker.leftClickMessage()+"：建物1枚\n"+DeviceChecker.rightClickMessage()+"：捨札（建物コストの枚数）"

  @use:(leftIndexs, rightIndexs)->
    #return "指定カードが足りません" unless super()

    # 建物は1枚でなければならない
    return "建物を1枚選択しなければなりません" if leftIndexs.length isnt 1

    buildCardIndex = leftIndexs[0]
    buildCardNum = HandSpace.getCardNum buildCardIndex
    cardClass    = HandSpace.getCardClass buildCardIndex
    cost = cardClass.getCost()

    # 建物は消費財であってはならない
    return "消費財は建設できません" unless cardClass.isBuildable()

    # 捨札は、コストと同一でなければならない
    return "捨札が建設コストと一致していません" if cost isnt rightIndexs.length

    # 建物を建てる
    PrivateSpace.push buildCardNum
    # 建物と捨札を捨てる
    HandSpace.trash rightIndexs, leftIndexs

    # カードを2枚引く
    Game.pullDeck 2

    true

# No.30 化学工場
class Card30 extends CardBase
  @NAME        = "化学工場"
  @CATEGORY    = "工業"
  @DESCRIPTION = "カードを2枚引く\n手札がなければ4枚引く"
  @COST        = 4
  @PRICE       = 9

  @use:->
    # 手札がなければ
    if HandSpace.getAmount() is 0
      # カードを4枚引く
      Game.pullDeck 4
    # あれば
    else
      # カードを2枚引く
      Game.pullDeck 2

    true

# No.31 労働組合
class Card31 extends CardBase
  @NAME        = "労働組合"
  @CATEGORY    = "施設"
  @DESCRIPTION = "終了時：労働者1人につき+6点\n売却不可"
  @COST        = 4
  @PRICE       = 0

# No.32 邸宅
class Card32 extends CardBase
  @NAME        = "邸宅"
  @CATEGORY    = "施設"
  @DESCRIPTION = "売却不可"
  @COST        = 4
  @PRICE       = 14

# No.33 自動車工場
class Card33 extends CardBase
  @NAME        = "自動車工場"
  @CATEGORY    = "工業"
  @DESCRIPTION = "手札を3枚捨てる\nカードを7枚引く"
  @COST        = 5
  @PRICE       = 12

  @requireCards:->
    [3,0]

  @getSelectMessage:->
    "選択してください\n"+DeviceChecker.leftClickMessage()+"：捨札3枚"

  @use:(leftIndexs)->
    return "捨札3枚が選択されていません" unless super

    # 捨札3枚を捨てる
    HandSpace.trash leftIndexs
    # カードを7枚引く
    Game.pullDeck 7

    true

# No.34 二胡市建設
class Card34 extends CardBase
  @NAME        = "二胡市建設"
  @DESCRIPTION = "同じコストの建物を2つ作る\n1つ分のコストだけ支払う"
  @COST        = 5
  @PRICE       = 10

  @requireCards:->
    [2,1]

  @getSelectMessage:->
    "選択してください\n"+DeviceChecker.leftClickMessage()+"：建物カード2枚\n"+DeviceChecker.rightClickMessage()+"：捨札（建物コストの枚数）"

  @use:(leftIndexs, rightIndexs)->
    #return "指定カードが足りません" unless super

    # 建物は2枚でなければならない
    return "建物を2枚選択しなければなりません" if leftIndexs.length isnt 2

    buildCardIndex0 = leftIndexs[0]
    buildCardNum0 = HandSpace.getCardNum buildCardIndex0
    cardClass0    = HandSpace.getCardClass buildCardIndex0
    cost0 = cardClass0.getCost()

    buildCardIndex1 = leftIndexs[1]
    buildCardNum1 = HandSpace.getCardNum buildCardIndex1
    cardClass1    = HandSpace.getCardClass buildCardIndex1
    cost1 = cardClass1.getCost()

    # 建物は消費財であってはならない
    return "消費財は建設できません" unless cardClass0.isBuildable() and cardClass1.isBuildable()

    # コストが一致していなければならない
    return "建物カードのコストが一致していません" if cost0 isnt cost1

    # 捨札は、コストと同一でなければならない
    return "捨札が建設コストと一致していません" if cost0 isnt rightIndexs.length

    # 建物を建てる
    PrivateSpace.push buildCardNum0
    PrivateSpace.push buildCardNum1
    # 建物と捨札を捨てる
    HandSpace.trash rightIndexs, leftIndexs

    true

# No.35 鉄道
class Card35 extends CardBase
  @NAME        = "鉄道"
  @CATEGORY    = "施設"
  @DESCRIPTION = "終了時：所有する工業カテゴリの建物1つにつき+8点\n売却不可"
  @COST        = 5
  @PRICE       = 9

# No.36 本社ビル
class Card36 extends CardBase
  @NAME        = "本社ビル"
  @CATEGORY    = "施設"
  @DESCRIPTION = "終了時：所有する施設カテゴリの建物1つにつき+6点\n売却不可"
  @COST        = 5
  @PRICE       = 10

# No.99 消費財
class Card99 extends CardBase
  @NAME        = "消費財"
  @CATEGORY    = "消費財"
  @DESCRIPTION = "捨札や建設コストとして捨てられる"
