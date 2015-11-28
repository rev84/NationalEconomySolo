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
    # 3枚デッキから引く
    @pullDeck() for i in [0...3]
    # デッキの一番上に工場を乗せる
    @objs.deck.place 17
    # 4枚公共に置く
    @pullPublic 4

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
    @cards = []

  # 建物を配置する
  @push:(cardNum)->
    @cards.push cardNum

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
    e = $('<div>').addClass('public')

    # ヘッダ
    # [コスト]カード名
    costStr = if cardClass.isPublicOnly() then '' else '['+cost+']'
    header = $('<span>').addClass('public_header').html(costStr+cardClass.getName())

    # 画像
    img = cardClass.getImageObj().addClass('public_image')

    # フッタ
    # カテゴリ
    catStr = if cat? then '['+cat+']' else ''
    categorySpan = $('<span>').addClass('public_footer public_category').html(catStr)
    # 得点
    pointStr = if cardClass.isPublicOnly() then '' else '[$'+point+']'
    pointSpan = $('<span>').addClass('public_footer public_point').html(pointStr)

    # 説明の吹き出し
    costBalloon = if cardClass.isPublicOnly() then '-' else cost
    priceBalloon = if cardClass.isPublicOnly() then '-' else price
    pointBalloon = if cardClass.isPublicOnly() then '-' else point
    catBalloon = if cat? then cat else 'なし'
    balloonStr = """
    #{desc}
    --------------------
    カテゴリ：#{catBalloon}
    コスト：#{costBalloon}
    売却価格：#{pointBalloon}
    得点：#{point}
    """.replace /\n/g, '<br>'
    e.attr('data-tooltip', balloonStr).darkTooltip()

    e.append header
    e.append img
    e.append categorySpan
    e.append pointSpan
    e



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
    # カテゴリ
    catStr = if cat? then '['+cat+']' else ''
    categorySpan = $('<span>').addClass('hand_footer hand_category').html(catStr)
    # 得点
    pointSpan = $('<span>').addClass('hand_footer hand_point').html('[$'+point+']')

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
    e.append categorySpan
    e.append pointSpan
    e

class RoundDeck
  @deck : []

  @init:->
    @deck = [
      2
      3
      4
      13
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

  # カードを乗せる
  @place:(cardNum)->
    @deck.unshift(cardNum)

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
      13 : 7  # 農場は1枚抜く
      14 : 4
      15 : 2
      16 : 2
      17 : 7  # 工場は1枚抜く
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
