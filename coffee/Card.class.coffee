class Card
  @getClass = (classNum)->
    try
      res = eval("Card"+classNum)
    catch
      return false
    return false if res?
    res

class CardBase
  # カードの名称
  @NAME = null
  # カードのカテゴリ
  @CATEGORY = null
  # カードの説明文
  @DESCRIPTION = null


# No.01 採石場 一人用プレイの場合は使用しない

# No.02 鉱山
class Card2 extends CardBase
  @NAME = "鉱山"

# No.03 学校
class Card3 extends CardBase
  @NAME = "学校"

# No.04 大工
class Card4 extends CardBase
  @NAME = "大工"

# No.05 露店
class Card5 extends CardBase
  @NAME = "露店"

# No.06 市場
class Card6 extends CardBase
  @NAME = "市場"

# No.07 高等学校
class Card7 extends CardBase
  @NAME = "高等学校"

# No.08 スーパーマーケット
class Card8 extends CardBase
  @NAME = "スーパーマーケット"

# No.09 大学
class Card9 extends CardBase
  @NAME = "大学"

# No.10 百貨店
class Card10 extends CardBase
  @NAME = "百貨店"

# No.11 専門学校
class Card11 extends CardBase
  @NAME = "専門学校"

# No.12 万博
class Card12 extends CardBase
  @NAME = "万博"

# No.13 農場
class Card13 extends CardBase
  @NAME = "農場"

# No.14 設計事務所
class Card14 extends CardBase
  @NAME = "設計事務所"

# No.15 焼畑
class Card15 extends CardBase
  @NAME = "焼畑"

# No.16 珈琲店
class Card16 extends CardBase
  @NAME = "珈琲店"

# No.17 工場
class Card17 extends CardBase
  @NAME = "工場"

# No.18 建設会社
class Card18 extends CardBase
  @NAME = "建設会社"

# No.19 果樹園
class Card19 extends CardBase
  @NAME = "果樹園"

# No.20 倉庫
class Card20 extends CardBase
  @NAME = "倉庫"

# No.21 社宅
class Card21 extends CardBase
  @NAME = "社宅"

# No.22 法律事務所
class Card22 extends CardBase
  @NAME = "法律事務所"

# No.23 大農園
class Card23 extends CardBase
  @NAME = "大農園"

# No.24 レストラン
class Card24 extends CardBase
  @NAME = "レストラン"

# No.25 開拓民
class Card25 extends CardBase
  @NAME = "開拓民"

# No.26 不動産屋
class Card26 extends CardBase
  @NAME = "不動産屋"

# No.27 農協
class Card27 extends CardBase
  @NAME = "農協"

# No.28 製鉄所
class Card28 extends CardBase
  @NAME = "製鉄所"

# No.29 ゼネコン
class Card29 extends CardBase
  @NAME = "ゼネコン"

# No.30 化学工場
class Card30 extends CardBase
  @NAME = "化学工場"

# No.31 労働組合
class Card31 extends CardBase
  @NAME = "労働組合"

# No.32 邸宅
class Card32 extends CardBase
  @NAME = "邸宅"

# No.33 自動車工場
class Card33 extends CardBase
  @NAME = "自動車工場"

# No.34 二胡市建設
class Card34 extends CardBase
  @NAME = "邸宅"

# No.35 鉄道
class Card35 extends CardBase
  @NAME = "鉄道"

# No.36 本社ビル
class Card36 extends CardBase
  @NAME = "本社ビル"

# No.99 消費財
class Card99 extends CardBase
  @NAME = "消費財"
