class Dialog
  header: ''
  content: ''
  buttons: null
  attachment: null

  destructionDelay: 500
  attachmentDelay: 60

  el: null
  headerContainer: null
  contentContainer: null
  buttonConatiner: null

  boundAttach: null

  constructor: (params = {}) ->
    @[property] = value for own property, value of params when property of @
    @buttons ||= []
    @attachment ||= to: null, at: {}

    @el = $('''
      <div class="zootorial-dialog">
        <button name="close">&times;</button>
        <div class="header"></div>
        <div class="content"></div>
        <div class="footer"></div>
      </div>
    ''')

    children = @el.children()
    @headerContainer = children.filter '.header'
    @contentContainer = children.filter '.content'
    @buttonConatiner = children.filter '.footer'

    @el.on 'click', 'button[name="close"]', => @close()

    @render()

    @el.css display: 'none'
    @el.appendTo 'body'

  render: ->
    @headerContainer.html @header
    @contentContainer.html @content

    @buttonConatiner.empty()
    for button, i in @buttons
      if typeof button in ['string', 'number']
        button = $("<button data-index='#{i}'>#{button}</button>")
      else
        for key, value of button
          button = $("<button value='#{value}'>#{key}</button>")

      @buttonConatiner.append button

  attach: ->
    wait @attachmentDelay, =>
      elPos = [@attachment.x, @attachment.y]
      atPos = [@attachment.at.x, @attachment.at.y]
      margin = @attachment.margin || @attachment.at.margin
      attach @el, elPos, @attachment.to, atPos, {margin}
      @el.trigger 'attach-dialog', [@]

  open: ->
    @el.css display: ''
    wait =>
      @el.removeClass 'hidden'
      @attach()
      @boundAttach = => @attach()
      $(window).on 'resize', @boundAttach
      @el.trigger 'open-dialog', [@]

  close: ->
    @el.addClass 'hidden'
    wait @destructionDelay, =>
      @el.css display: 'none'
      $(window).off 'resize', @boundAttach
      @boundAttach = null
      @el.trigger 'close-dialog', [@]

  destroy: ->
    wait @destructionDelay, =>
      @el.trigger 'destroy-dialog', [@]
      @el.remove()
      @el.off()
