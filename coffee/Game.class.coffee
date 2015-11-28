class window.Game
  @objs : {}
  @isSetObj : false

  @init : ->
    @setObj()
    obj.init() for name, obj of @objs

  @setObj : ->
    return if @isSetObj
    @isSetObj = true
    @objs.public   = PublicSpace
    @objs.private  = PrivateSpace
    @objs.hand     = HandSpace
    @objs.log      = LogSpace
    @objs.budget   = Budget
    @objs.round    = RoundDeck
    @objs.deck     = Deck
    @objs.consumer = Consumer

  @gameStart:->
    @init()
    # 3枚配る
    @pull2hand() for i in [0...3]

  # カードをデッキから手札に移動
  @pull2hand:(amount = 1)->
    @objs.hand.push @objs.deck.pull() for i in [0...amount]

class SpaceBase
  @DIV_ID = null
  @init:->
    e = @getElement()
    e.html(@DIV_ID)

  @getElement:->
    $('#'+@DIV_ID)


class PublicSpace extends SpaceBase
  @DIV_ID = "public"

  @cards:[]

  @init:->
    super()
    @cards = {}
  @insert:(cardObj)->

class PrivateSpace extends SpaceBase
  @DIV_ID = "private"

  @cards:[]

  @init:->
    super()

class LogSpace extends SpaceBase
  @DIV_ID = "log"
  @init:->
    super()
  # ログのクリア
  @clear:->
    @getElement().html('')
  # 通常のログ
  @output:(message)->
  # エラーログ
  @error:(message)->
  # 致命的なエラーログ
  @fatal:(message)->

class HandSpace extends SpaceBase
  @DIV_ID = "hand"
  @cards : []
  @init:->
    super()
  # ソートする
  @sort:->
    @cards.sort()

  # 手札を増やす
  @push:(cardNum)->
    @cards.push cardNum
    @sort()
    @redraw()

  # 描画
  @redraw:->
    me = @getElement()

    me.html('')
    for index in [0...@cards.length]
      me.append @createElement index

  # 要素作成
  @createElement:(index)->
    # ハンドになければ脱出
    return false unless @cards[index]?

    # カードのクラス
    cardClass = Card.getClass @cards[index]
    # カード名
    name = cardClass.getName()
    # カテゴリ
    cat = cardClass.getCategory()
    # コスト
    price = cardClass.getPrice()
    # コスト
    cost = cardClass.getCost()
    # 得点
    point = cardClass.getPoint()
    # 説明文
    desc = cardClass.getDescription()

    # カードの外側
    e = $('<div>').addClass('hand')

    # ヘッダ
    # [コスト]カード名
    header = $('<span>').addClass('hand_header').html('['+cost+']'+cardClass.getName())

    # 画像
    img = cardClass.getImageObj().addClass('hand_image')

    # フッタ
    # [カテゴリ][得点]
    catStr = if cat? then '['+cat+']' else ''
    footer = $('<span>').addClass('hand_footer').html(catStr+'[$'+point+']')

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

    e.append header
    e.append img
    e.append footer
    e

class RoundDeck
  @deck : []

  @init:->
    @deck = [
      5
      6
      7
      8
      9
      10
      11
      12
    ]

  # カードを引く
  @pull:->
    false if @deck.length is 0
    @deck.shift()

class Deck
  # 山札
  @deck : []
  # 墓地
  @grave : []

  @init:->
    @deck = []
    def = @getCardDefine()
    for cardNum, amount of def
      @deck.push cardNum for i in [0...amount]
    @shuffle()

    @grave = []

  # カードを引く
  @pull:->
    @recycle() if @deck.length is 0
    @deck.pop()

  # カードを捨てる
  @trash:(cardNum)->
    @grave.push cardNum

  # 墓地から山札に戻してシャッフル
  @recycle:()->
    @deck.push cardNum for cardNum in @grave
    @grave = []
    @shuffle()

  # シャッフル
  @shuffle:->
    copy = []
    n = @deck.length
    while n
      i = Math.floor(Math.random() * n--)
      copy.push @deck.splice(i, 1)[0]
    @deck = copy

  # カードの枚数定義
  @getCardDefine:->
    res =
      13 : 8
      14 : 4
      15 : 2
      16 : 2
      17 : 8
      18 : 4
      19 : 3
      20 : 3
      21 : 2
      22 : 1
      23 : 3
      24 : 2
      25 : 2
      26 : 2
      27 : 1
      28 : 3
      29 : 3
      30 : 2
      31 : 1
      32 : 1
      33 : 3
      34 : 2
      35 : 1
      36 : 1
    res

# 消費財デッキ
class Consumer
  @init:->
  # カードを引く
  @pull:->
    99

# 家計
class Budget
  @money : 0

  @init:->
    @money = 0

  # 給料を払う
  @push:(amount)->
    return false if amount < 0
    @money += amount

  # 家計から徴収
  @pull:(amount)->
    return false if amount < 0
    return false if @money < amount
    @money -= amount

  # 金額を知る
  @getAmount:->
    @money
