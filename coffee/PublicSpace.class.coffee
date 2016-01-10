class PublicSpace extends CardSpace
  @DIV_ID = "public"

  # バルーンにつけるクラス
  @BALLOON_CLASS_NAME = 'balloon_public'

  # 建物の状態
  @status:[]

  @init:->
    super()
    @status = []

  # すべて使用可能にする
  @resetStatus:->
    @status[index] = @STATUS_USABLE for index in [0...@cards.length]

  # カードクラスの取得
  @getCardClass:(index)->
    return Card.getClass(@cards[index])

  @isUsable:(index)->
    # 鉱山は無限に使える
    return true if @cards[index] is Card.CARD_NUM_KOUZAN
    # 存在しない
    return false unless @status[index]?
    # 使用可能状態でない
    return false if @status[index] isnt @STATUS_USABLE
    true

  # 労働者を置く
  @setWorked:(index)->
    return false if @isUsable index is false
    @status[index] = @STATUS_WORKED

  # 時間経過労働者を置く
  @setDisabled:(index)->
    return false if @isUsable index is false
    @status[index] = @STATUS_DISABLED

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

  # 最新の建物を使用不能にする
  @disableLastest:->
    for index in [@status.length-1..0]
      if @status[index] is @STATUS_USABLE
        @status[index] = @STATUS_DISABLED
        break

  # ダブルクリック時には労働者を配置する
  @cardDoubleClickAction:(elem)->
    index = $(elem).attr('data-index')
    Game.work 'public', index

  @additionalCardAction:(elem, index)->
    # 労働者により使用不可
    switch @status[index]
      when @STATUS_WORKED
        elem.addClass('card_used') if @cards[index] isnt Card.CARD_NUM_KOUZAN
        elem.append $('<img>').attr('src', @IMG_WORKER).addClass('card_worker')
      when @STATUS_DISABLED
        elem.addClass('card_used')
        elem.append $('<img>').attr('src', @IMG_DISABLER).addClass('card_worker')
