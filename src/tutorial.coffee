factory = ($, Step, Dialog) ->
  class Tutorial
    @Step = Step

    steps: null
    step: -1

    hidden: false

    constructor: (params = {}) ->
      @[property] = value for own property, value of params when property of @

      @dialog = new Dialog params

      @dialog.el.on 'click', 'button[name="close"]', =>
        @end();

    start: =>
      @dialog.el.trigger 'start-tutorial'
      @dialog.el.addClass 'tutorial'
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

    hide: ->
      @hidden = true
      step = @steps[@step]
      return unless step?
      step.exit @
      @dialog.close()

    show: ->
      return unless @hidden
      step = @steps[@step]
      return unless step?
      step.enter @
      @dialog.open()
      @hidden = false

    end: =>
      @dialog.el.trigger 'end-tutorial'
      @dialog.el.removeClass 'tutorial'
      @steps[@step]?.exit @
      @dialog.close()
      @step = -1

  Tutorial

if define?.amd
  define ['jquery', './step', './dialog'], factory
else
  jQuery = window.jQuery
  Step = window.zootorial?.Step
  Dialog = window.zootorial?.Dialog

  if module?.exports
    Step ?= require './step'
    Dialog ?= require './dialog'
    module.exports = factory jQuery, Dialog
  else
    window.zootorial ?= {}
    window.zootorial.Tutorial = factory jQuery, Step, Dialog
