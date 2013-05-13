class Step
  className: ''
  header: ''
  content: ''
  attachment: null
  buttons: null
  nextOn: null
  defaultButton: 'Continue'
  block: ''
  focus: ''
  onEnter: null
  onExit: null

  tutorialNext: null
  blockers: null
  focusers: null

  started: null

  constructor: (params = {}) ->
    @[property] = value for own property, value of params when property of @
    
    @attachment ?= to: null
    @attachment.at ?= {}

    if (not @buttons) and (not @nextOn)
      button = {}
      button[@defaultButton] = 'ZOOTORIAL_NEXT'
      @buttons = [button]
      @nextOn = click: 'button[value="ZOOTORIAL_NEXT"]'

    @buttons ?= []
    @nextOn ?= click: '.tutorial.zootorial-dialog'

  createBlockers: ->
    @blockers = $()
    for blocked in $(@block)
      blocked = $(blocked)
      blocker = $('<div class="hidden zootorial-blocker"></div>')
      blocker.width blocked.outerWidth()
      blocker.height blocked.outerHeight()
      blocker.offset blocked.offset()
      @blockers = @blockers.add blocker

  createFocusers: ->
    focuserMarkup = '<div class="hidden zootorial-focuser"></div>'
    @focusers = $(focuserMarkup + focuserMarkup + focuserMarkup + focuserMarkup)

    focus = $(@focus).filter(':visible').first()
    return if focus.length is 0

    offset = focus.offset()
    width = focus.outerWidth()
    height = focus.outerHeight()

    totalHeight = $('html').outerHeight()
    totalWidth = $('html').outerWidth()

    above = @focusers.eq 0
    above.offset left: 0, top: 0
    above.width '100%'
    above.height offset.top

    right = @focusers.eq 1
    right.offset left: offset.left + width, top: offset.top
    right.width totalWidth - offset.left - width
    right.height height

    bottom = @focusers.eq 2
    bottom.offset left: 0, top: offset.top + height
    bottom.width '100%'
    bottom.height totalHeight - offset.top - height

    left = @focusers.eq 3
    left.offset left: 0, top: offset.top
    left.width offset.left
    left.height height

  enter: (tutorial) ->
    @started = new Date

    @onEnter? tutorial, @

    tutorial.dialog.el.addClass @className if @className
    tutorial.dialog.header = @header
    tutorial.dialog.content = @content
    tutorial.dialog.buttons = @buttons
    tutorial.dialog.attachment = @attachment
    tutorial.dialog.render()
    tutorial.dialog.attach()

    @tutorialNext = =>
      @complete tutorial
      tutorial.next()

    for eventName, selector of @nextOn
      $(document).on eventName, selector, @tutorialNext

    @createBlockers()
    @createFocusers()

    extras = @blockers.add(@focusers)
    extras.appendTo Step.parent
    extras.css position: 'absolute'
    setTimeout $.proxy(extras, 'removeClass', 'hidden'), tutorial.dialog.attachmentDelay

    tutorial.dialog.el.trigger 'enter-tutorial-step', [tutorial.step, @, tutorial]

  complete: (tutorial) ->
    finished = (new Date) - @started
    sleuth?.logCustomEvent {type: 'complete-tutorial-step', value: tutorial.step}
    tutorial.dialog.el.trigger 'complete-tutorial-step', [tutorial.step, @, tutorial, {finished}]

  exit: (tutorial) ->
    @onExit? tutorial, @

    tutorial.dialog.el.removeClass @className if @className

    for eventName, selector of @nextOn
      $(document).off eventName, selector, @tutorialNext

    extras = @blockers.add(@focusers)
    extras.addClass 'hidden'
    setTimeout $.proxy(extras, 'remove'), tutorial.dialog.attachmentDelay

    finished = (new Date) - @started
    tutorial.dialog.el.trigger 'exit-tutorial-step', [tutorial.step, @, tutorial, {finished}]
