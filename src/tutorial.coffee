class Tutorial
  @Step = Step

  title: 'Untitled'
  steps: null
  step: -1
  parent: 'body'

  started: null

  constructor: (params = {}) ->
    @[property] = value for own property, value of params when property of @
    
    @dialog = new Dialog params
    @dialog.el.addClass 'tutorial'

    @dialog.el.on 'close-dialog', => @end()
    
    Step.parent = @parent

  start: ->
    @started = new Date
    @goTo 0
    @dialog.open()
    @dialog.el.trigger 'start-tutorial', [@]

  next: ->
    @goTo @step + 1

  goTo: (step) ->
    @steps[@step]?.exit @

    @step = step

    if @steps[@step]
      @steps[@step].enter @
    else
      @complete()

  complete: ->
    finished = new Date - @started
    @dialog.close()
    @dialog.el.trigger 'complete-tutorial', [@, {finished}]

  end: ->
    finished = new Date - @started
    onStep = Math.min @step, @steps.length - 1
    @steps[@step]?.exit @
    @step = -1
    @started = null
    @dialog.el.trigger 'end-tutorial', [@, {onStep, finished}]
