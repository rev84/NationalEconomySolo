class Card
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

  # 労働者を置けるか
  @isWorkable:->
    return false if @CATEGORY is '非職場'
    return false if @CATEGORY is '消費財'
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
  @DESCRIPTION = "カードを1枚引く"

# No.03 学校
class Card3 extends CardBase
  @NAME        = "学校"
  @CATEGORY    = "公共"
  @DESCRIPTION = "労働者を1人増やす"

# No.04 大工
class Card4 extends CardBase
  @NAME        = "大工"
  @CATEGORY    = "公共"
  @DESCRIPTION = "建物を1つ作る"

# No.05 露店
class Card5 extends CardBase
  @NAME        = "露店"
  @CATEGORY    = "公共"
  @DESCRIPTION = "手札を1枚捨てる\n家計から$6を得る"

# No.06 市場
class Card6 extends CardBase
  @NAME        = "市場"
  @CATEGORY    = "公共"
  @DESCRIPTION = "手札を2枚捨てる\n家計から$12を得る"

# No.07 高等学校
class Card7 extends CardBase
  @NAME        = "高等学校"
  @CATEGORY    = "公共"
  @DESCRIPTION = "労働者を4人に増やす"

# No.08 スーパーマーケット
class Card8 extends CardBase
  @NAME        = "スーパーマーケット"
  @CATEGORY    = "公共"
  @DESCRIPTION = "手札を3枚捨てて家計から$18を得る"

# No.09 大学
class Card9 extends CardBase
  @NAME        = "大学"
  @CATEGORY    = "公共"
  @DESCRIPTION = "労働者を5人に増やす"

# No.10 百貨店
class Card10 extends CardBase
  @NAME        = "百貨店"
  @CATEGORY    = "公共"
  @DESCRIPTION = "手札を4枚捨てて家計から$24を得る"

# No.11 専門学校
class Card11 extends CardBase
  @NAME        = "専門学校"
  @CATEGORY    = "公共"
  @DESCRIPTION = "労働者を1人増やす\nこのラウンドからすぐ働ける"

# No.12 万博
class Card12 extends CardBase
  @NAME        = "万博"
  @CATEGORY    = "公共"
  @DESCRIPTION = "手札を5枚捨てて家計から$30を得る"

# No.13 農場
class Card13 extends CardBase
  @NAME        = "農場"
  @CATEGORY    = "農業"
  @DESCRIPTION = "消費財を2枚引く"
  @COST        = 1
  @PRICE       = 3

# No.14 設計事務所
class Card14 extends CardBase
  @NAME        = "設計事務所"
  @DESCRIPTION = "カードを5枚めくり公開する\nうち1枚を引いて残りを捨てる"
  @COST        = 1
  @PRICE       = 4

# No.15 焼畑
class Card15 extends CardBase
  @NAME        = "焼畑"
  @CATEGORY    = "農業"
  @DESCRIPTION = "消費財を5枚引く\n焼畑は消滅する"
  @COST        = 1
  @PRICE       = 0

# No.16 珈琲店
class Card16 extends CardBase
  @NAME        = "珈琲店"
  @DESCRIPTION = "家計から$5を得る"
  @COST        = 1
  @PRICE       = 4

# No.17 工場
class Card17 extends CardBase
  @NAME        = "工場"
  @CATEGORY    = "工業"
  @DESCRIPTION = "手札を2枚捨てる\nカードを4枚引く"
  @COST        = 2
  @PRICE       = 6

# No.18 建設会社
class Card18 extends CardBase
  @NAME        = "建設会社"
  @DESCRIPTION = "建物を1つコスト-1で作る\n"
  @COST        = 2
  @PRICE       = 5

# No.19 果樹園
class Card19 extends CardBase
  @NAME        = "果樹園"
  @CATEGORY    = "農業"
  @DESCRIPTION = "手札を2枚捨てる\nカードを4枚引く"
  @COST        = 2
  @PRICE       = 5

# No.20 倉庫
class Card20 extends CardBase
  @NAME        = "倉庫"
  @CATEGORY    = "非職場"
  @DESCRIPTION = "手札上限+4\n（所有しているだけで効果がある）\n売却不可"
  @COST        = 2
  @PRICE       = 5

# No.21 社宅
class Card21 extends CardBase
  @NAME        = "社宅"
  @CATEGORY    = "非職場"
  @DESCRIPTION = "労働者上限+1\n（所有しているだけで効果がある）\n売却不可"
  @COST        = 2
  @PRICE       = 4

# No.22 法律事務所
class Card22 extends CardBase
  @NAME        = "法律事務所"
  @CATEGORY    = "非職場"
  @DESCRIPTION = "終了時：負債から5枚まで免除する"
  @COST        = 2
  @PRICE       = 4

# No.23 大農園
class Card23 extends CardBase
  @NAME        = "大農園"
  @CATEGORY    = "農業"
  @DESCRIPTION = "消費財を3枚引く"
  @COST        = 3
  @PRICE       = 6

# No.24 レストラン
class Card24 extends CardBase
  @NAME        = "レストラン"
  @DESCRIPTION = "手札を1枚捨てる\n家計から$15を得る"
  @COST        = 3
  @PRICE       = 8

# No.25 開拓民
class Card25 extends CardBase
  @NAME        = "開拓民"
  @DESCRIPTION = "手札の農業カテゴリの建物を1つコスト0で作る"
  @COST        = 3
  @PRICE       = 7

# No.26 不動産屋
class Card26 extends CardBase
  @NAME        = "不動産屋"
  @CATEGORY    = "非職場"
  @DESCRIPTION = "終了時：所有する建物1つにつき+3点\n（この建物を含む）\n売却不可"
  @COST        = 3
  @PRICE       = 5

# No.27 農協
class Card27 extends CardBase
  @NAME        = "農協"
  @CATEGORY    = "非職場"
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

# No.29 ゼネコン
class Card29 extends CardBase
  @NAME        = "ゼネコン"
  @DESCRIPTION = "建物を1つ作る\nカードを2枚引く"
  @COST        = 4
  @PRICE       = 9

# No.30 化学工場
class Card30 extends CardBase
  @NAME        = "化学工場"
  @CATEGORY    = "工業"
  @DESCRIPTION = "カードを2枚引く\n手札がなければ4枚引く"
  @COST        = 4
  @PRICE       = 9

# No.31 労働組合
class Card31 extends CardBase
  @NAME        = "労働組合"
  @CATEGORY    = "非職場"
  @DESCRIPTION = "終了時：労働者1人につき+6点\n売却不可"
  @COST        = 4
  @PRICE       = 0

# No.32 邸宅
class Card32 extends CardBase
  @NAME        = "邸宅"
  @CATEGORY    = "非職場"
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

# No.34 二胡市建設
class Card34 extends CardBase
  @NAME        = "二胡市建設"
  @DESCRIPTION = "同じコストの建物を2つ作る\n1つ分のコストだけ支払う"
  @COST        = 5
  @PRICE       = 10

# No.35 鉄道
class Card35 extends CardBase
  @NAME        = "鉄道"
  @CATEGORY    = "非職場"
  @DESCRIPTION = "終了時：所有する鉱業カテゴリの建物1つにつき+3点\n売却不可"
  @COST        = 5
  @PRICE       = 9

# No.36 本社ビル
class Card36 extends CardBase
  @NAME        = "本社ビル"
  @CATEGORY    = "非職場"
  @DESCRIPTION = "終了時：所有する非職場カテゴリの建物1つにつき+3点\n売却不可"
  @COST        = 5
  @PRICE       = 10

# No.99 消費財
class Card99 extends CardBase
  @NAME        = "消費財"
  @CATEGORY    = "消費財"
  @DESCRIPTION = "手札やコストとして捨てられる"
