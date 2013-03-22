class Dialog
  content: ''
  attachment: null

  parent: document.body
  el: null
  contentContainer: null

  constructor: (params = {}) ->
    @[property] = value for own property, value of params when property of @

    @attachment ?= to: null, at: {}

    @el = $('''
      <div class="zootorial-dialog">
        <button name="close-dialog">&times;</button>
        <div class="dialog-content"></div>
        <div class="dialog-arrow"></div>
      </div>
    ''')

    @contentContainer = @el.find '.dialog-content'

    @el.on 'click', 'button[name="close-dialog"]', =>
      @el.trigger 'click-close-dialog', [@]
      @close()

    $(window).on 'resize', => @attach()

    @el.appendTo @parent

  render: (@content = @content) ->
    @contentContainer.html @content
    @attach()
    @el.trigger 'render-dialog', [@, @content]

  attach: (@attachment = @attachment) ->
    return unless @el.hasClass 'open'
    elPos = [@attachment.x, @attachment.y]
    atPos = [@attachment.at.x, @attachment.at.y]
    margin = @attachment.margin || @attachment.at.margin
    attach @el, elPos, @attachment.to, atPos, {margin}
    @el.trigger 'attach-dialog', [@, @attachment]

  open: ->
    return if @el.hasClass 'open'
    @el.css display: 'none'
    @el.addClass 'open'
    @render()
    setTimeout => @el.css display: ''
    @el.trigger 'open-dialog', [@]

  close: ->
    return unless @el.hasClass 'open'
    @el.removeClass 'open'
    @el.trigger 'close-dialog', [@]

  destroy: ->
    @close()
    @el.remove()
    @el.trigger 'destroy-dialog', [@]
    @el.off()
