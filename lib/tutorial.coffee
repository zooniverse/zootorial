factory = ($, Dialog) ->
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

    class @Step
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

        @createBlockers()
        @createFocusers()

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

  Tutorial

if define?.amd
  define ['jquery', './dialog'], factory
else
  jQuery = window.jQuery
  Dialog = window.zootorial?.Dialog

  if module?.exports
    Dialog ?= require './dialog'
    module.exports = factory jQuery, Dialog
  else
    window.zootorial ?= {}
    window.zootorial.Tutorial = factory jQuery, Dialog
