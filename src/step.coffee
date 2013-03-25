class Step
  className: ''

  # The following can be string, function, or jQuery objects.
  number: NaN # One-indexed!
  header: ''
  details: ''
  instruction: ''
  buttons: ''

  next: null
  nextButton: 'Continue'

  attachment: 'center middle window center middle'

  block: '' # Prevent these from being clicked.
  focus: '' # Block everything but this (limited to one element).
  actionable: '' # These get a special class.

  onEnter: null
  onExit: null

  started: null

  constructor: (params = {}) ->
    @[property] = value for own property, value of params when property of @

  enter: (tutorial) ->
    @started = new Date

    @onEnter? tutorial

    wait =>
      @createBlockers()
      @createFocusers()

      $(@actionable).addClass 'actionable'

      extras = @blockers.add(@focusers)
      extras.appendTo dialog.el.parent()
      wait => extras.removeClass 'hidden'

    tutorial.el.trigger 'enter-tutorial-step', [@, tutorial]

  createBlockers: ->
    @blockers = $()
    for blocked in $(@block)
      blocked = $(blocked)
      blocker = $('<div class="hidden zootorial-blocker"></div>')
      blocker.width blocked.outerWidth()
      blocker.height blocked.outerHeight()
      blocker.offset blocked.offset()
      @blockers = @blockers.add blocker
    @blockers.css position: 'absolute'

  createFocusers: ->
    focuserMarkup = '<div class="hidden zootorial-focuser"></div>'
    @focusers = $(focuserMarkup + focuserMarkup + focuserMarkup + focuserMarkup)
    @focusers.css position: 'absolute'

    focus = $(@focus).filter(':visible').first()
    return if focus.length is 0

    offset = focus.offset()
    width = focus.outerWidth()
    height = focus.outerHeight()

    totalHeight = $document.outerHeight()
    totalWidth = $document.outerWidth()

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

  exit: (tutorial) ->
    @onExit? tutorial

    extras = @blockers.add(@focusers)
    extras.addClass 'hidden'
    wait 250, =>
      extras.remove()
      $(@actionable).removeClass 'actionable'

    finished = (new Date) - @started
    @started = null
    tutorial.el.trigger 'exit-tutorial-step', [@, tutorial, finished]
