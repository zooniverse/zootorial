$ = window.jQuery

underlay = $('<div class="hidden dialog-underlay"></div>')
underlay.appendTo 'body'

attach = (el, [elX, elY], {to}, [toX, toY]) ->
  el = $(el)
  throw new Error 'Couldn\'t find an element to attach.' if el.length is 0

  to = $(to).filter(':visible').first()
  to = $(window) if to.length is 0

  elX ?= 'center'
  elY ?= 'middle'
  toX ?= 'center'
  toY ?= 'middle'

  positions =
    left: 0, center: 0.5, right: 1
    top: 0, middle: 0.5, bottom: 1

  elX = positions[elX] if elX of positions
  toY = positions[toY] if toY of positions
  elY = positions[elY] if elY of positions
  toX = positions[toX] if toX of positions

  toSize = width: to.outerWidth(), height: to.outerHeight()
  toOffset = to.offset() || left: 0, top: 0

  elSize = width: el.outerWidth(), height: el.outerHeight()
  newElOffset =
    left: toOffset.left - (elSize.width * elX) + (toSize.width * toX)
    top: toOffset.top - (elSize.height * elY) + (toSize.height * toY)

  el.offset newElOffset

class Dialog
  header: ''
  content: ''
  buttons: null
  attachment: null

  openImmediately: false
  destroyOnClose: false

  destructionDelay: 500
  attachmentDelay: 125

  underlay: underlay

  constructor: (params = {}) ->
    @[property] = value for own property, value of params when property of @
    @buttons ||= []
    @attachment ||= to: null, at: {}

    @el ||= $("<div class='dialog'></div>")
    @el = $(@el) unless @el instanceof $

    @el.html """
      <header></header>
      <div class="content"></div>
      <footer></footer>
    """

    @render()
    @el.appendTo 'body'

    @open() if @openImmediately

  render: ->
    header = @el.find('header').first()
    content = @el.find('.content').first()
    footer = @el.find('footer').last()

    texts = header: null, content: null
    for section in ['header', 'content']
      part = @[section]

      if typeof part is 'string'
        part = part.split '\n'

      if part instanceof Array
        part = $("<p>#{part.join '</p><p>'}</p>")

      texts[section] = part

    header.empty().append texts.header
    content.empty().append texts.content

    footer.empty()
    for button, i in @buttons
      if typeof button in ['string', 'number']
        button = $("<button data-index='#{i}'>#{button}</button>")
      else
        for key, value of button
          button = $("<button data-index='#{value}'>#{key}</button>")

      footer.append button

    @attach()

  attach: ->
    setTimeout @_attach, @attachmentDelay

  _attach: =>
    attach @el, [
      @attachment.x
      @attachment.y
    ], to: @attachment.to, [
      @attachment.at.x
      @attachment.at.y
    ]

  open: ->
    @underlay.removeClass 'hidden'
    @el.removeClass 'hidden'
    $(window).on 'resize', @_attach

  close: ->
    @underlay.addClass 'hidden'
    @el.addClass 'hidden'
    $(window).off 'resize', @_attach

    @destroy() if @destroyOnClose

  destroy: ->
    setTimeout @_destroy, @destructionDelay

  _destroy: =>
    @el.remove()

class Tutorial
  steps: null

  step: -1

  constructor: (params = {}) ->
    @[property] = value for own property, value of params when property of @

    @dialog = new Dialog params

  start: =>
    @dialog.el.addClass 'tutorial'
    @dialog.underlay.addClass 'tutorial'
    @goTo 0
    @dialog.open()

  next: =>
    @goTo @step + 1

  goTo: (step) =>
    @steps[@step]?.exit @

    @step = step
    if @steps[@step]
      @steps[@step].enter @
    else
      @end()

  end: =>
    @dialog.el.removeClass 'tutorial'
    @dialog.underlay.removeClass 'tutorial'
    @steps[@step]?.exit @
    @dialog.close()
    @step = -1

class Step
  header: ''
  content: ''
  buttons: null
  attachment: null
  className: ''
  nextOn: null
  block: ''
  focus: ''
  onEnter: null
  onExit: null

  blockers: null

  constructor: (params = {}) ->
    @[property] = value for own property, value of params when property of @
    @buttons ||= []
    @attachment ||= to: null, at: {}
    @nextOn ||= click: '.tutorial'
    @createBlockers()
    @createFocusers()

  createBlockers: ->
    @blockers = $()
    for blocked in $(@block)
      blocked = $(blocked)
      blocker = $('<div class="hidden tutorial-blocker"></div>')
      blocker.width blocked.outerWidth()
      blocker.height blocked.outerHeight()
      blocker.offset blocked.offset()
      @blockers = @blockers.add blocker

  createFocusers: ->
    @focusers = $((new Array 4 + 1).join '<div class="hidden tutorial-focuser"></div>')

    focus = $(@focus).filter(':visible').first()
    return if focus.length is 0

    offset = focus.offset()
    width = focus.outerWidth()
    height = focus.outerHeight()

    totalHeight = $('html').outerHeight()
    totalWidth = $('html').outerWidth()

    above = @focusers.eq(0)
    above.offset left: 0, top: 0
    above.width '100%'
    above.height offset.top

    right = @focusers.eq(1)
    right.offset left: offset.left + width, top: offset.top
    right.width totalWidth - offset.left - width
    right.height height

    bottom = @focusers.eq(2)
    bottom.offset left: 0, top: offset.top + height
    bottom.width '100%'
    bottom.height totalHeight - offset.top - height

    left = @focusers.eq(3)
    left.offset left: 0, top: offset.top
    left.width totalWidth - offset.left - width
    left.height height

  enter: (tutorial) ->
    @onEnter? tutorial, @
    tutorial.dialog.attachment = @attachment
    tutorial.dialog.header = @header
    tutorial.dialog.content = @content
    tutorial.dialog.buttons = @buttons
    tutorial.dialog.render()

    for eventName, selector of @nextOn
      $(document).on eventName, selector, tutorial.next

    extras = @blockers.add(@focusers)
    extras.appendTo 'body'
    setTimeout $.proxy($::removeClass, extras, 'hidden'), tutorial.dialog.attachmentDelay

  exit: (tutorial) ->
    @onExit? tutorial, @

    for eventName, selector of @nextOn
      $(document).off eventName, selector, tutorial.next

    extras = @blockers.add(@focusers)
    extras.addClass 'hidden'
    setTimeout $.proxy($::remove, extras), tutorial.dialog.attachmentDelay

Tutorial.attach = attach
Tutorial.Dialog = Dialog
Tutorial.Step = Step

if define?.amd
  define -> Tutorial
else if module?.exports
  module.exports = Tutorial
else
  window.Tutorial = Tutorial
