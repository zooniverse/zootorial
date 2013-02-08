factory = ($, Step, Dialog) ->
  class Tutorial
    @Step = Step

    steps: null
    step: -1

    constructor: (params = {}) ->
      @[property] = value for own property, value of params when property of @

      @dialog = new Dialog params
      @dialog.el.addClass 'tutorial'

    start: ->
      @goTo 0
      @dialog.open()
      @dialog.el.trigger 'start-tutorial'

    next: ->
      @goTo @step + 1

    goTo: (step) ->
      @steps[@step]?.exit @

      @step = step

      if @steps[@step]
        @steps[@step].enter @
      else
        @end()

    end: ->
      @steps[@step]?.exit @
      @dialog.close()
      @step = -1
      @dialog.el.trigger 'end-tutorial'

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
