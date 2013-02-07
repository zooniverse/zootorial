factory = ($) ->
  class Step
    header: ''
    content: ''
    buttons: null
    defaultButton: 'Continue'
    attachment: null
    className: ''
    nextOn: null
    block: ''
    focus: ''
    onEnter: null
    onExit: null

    blockers: null
    focusers: null

    constructor: (params = {}) ->
      @[property] = value for own property, value of params when property of @

      if (not @buttons) and (not @nextOn)
        button = {}
        button[@defaultButton] = 'ZOOTORIAL_NEXT'
        @buttons = [button]
        @nextOn = click: 'button[value="ZOOTORIAL_NEXT"]'

      @buttons ||= []
      @attachment ||= to: null
      @attachment.at ||= {}
      @nextOn ||= click: '.tutorial.zootorial-dialog'

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
      @focusers = $((new Array 4 + 1).join '<div class="hidden zootorial-focuser"></div>')

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
      tutorial.dialog.el.trigger 'enter-tutorial-step', [tutorial.step, @]

      @onEnter? tutorial, @

      tutorial.dialog.attachment = @attachment
      tutorial.dialog.header = @header
      tutorial.dialog.content = @content
      tutorial.dialog.buttons = @buttons
      tutorial.dialog.render()
      tutorial.dialog.el.addClass @className if @className

      for eventName, selector of @nextOn
        $(document).on eventName, selector, tutorial.next

      @createBlockers()
      @createFocusers()

      extras = @blockers.add(@focusers)
      extras.appendTo 'body'
      extras.css position: ''
      setTimeout $.proxy($::removeClass, extras, 'hidden'), tutorial.dialog.attachmentDelay

    exit: (tutorial) ->
      tutorial.dialog.el.trigger 'exit-tutorial-step', [tutorial.step, @]

      @onExit? tutorial, @

      tutorial.dialog.el.removeClass @className if @className

      for eventName, selector of @nextOn
        $(document).off eventName, selector, tutorial.next

      extras = @blockers.add(@focusers)
      extras.addClass 'hidden'
      setTimeout $.proxy($::remove, extras), tutorial.dialog.attachmentDelay

  Step

if define?.amd
  define ['jquery'], factory
else
  jQuery = window.jQuery

  if module?.exports
    module.exports = factory jQuery
  else
    window.zootorial ?= {}
    window.zootorial.Step = factory jQuery
