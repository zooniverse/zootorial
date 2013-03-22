STEP_PARTS = ['header', 'details', 'instruction', 'buttons']

class Tutorial extends Dialog
  id: ''

  steps: null
  firstStep: null
  currentStep: null
  nextStep: null

  header: null
  details: null
  instruction: null
  buttons: null

  started: null

  constructor: (params = {}) ->
    super
    @id ?= Math.random.toString(16).split('.')[1]
    @steps ?= []
    @firstStep ?= @steps[0] if @steps instanceof Array

    @el.addClass 'tutorial'

    @el.on 'click', 'button[name="next-step"]', =>
      @load @currentStep.next

    @content = $('''
      <div>
        <div class="header"></div>
        <div class="details"></div>
        <div class="instruction"></div>
        <div class="buttons"></div>
      </div>
    ''')

    for stepPart in STEP_PARTS
      @[stepPart] = @content.find ".#{stepPart}"

  load: (step) ->
    console.info 'Loading', step
    # Trying to load a true or null step in an array of steps will first try to load the next one.
    if ((step is true) or (not step?)) and @steps instanceof Array
      console.log 'Step is true or null, @steps is an array'
      index = i for step, i in @steps when step is @currentStep
      step = @steps[i + 1]

    # If the next step is null, the tutorial is complete.
    if not step?
      console.log 'Step is null, tutorial complete'
      @complete()
      return

    # If the next step is false, stay on the current step but highlight the instruction.
    if step is false
      console.log 'Step is false, highlight instruction'
      @instruction.addClass 'attention'
      return

    # If given a function, run it to find the actual step.
    if typeof step is 'function'
      step = step @
      console.log 'Step is function, returned:', step

    # You can refer to steps by their key or index.
    unless step instanceof Step
      step = @steps[step]
      console.log 'Step isn\'t the right class, found', step

    # We should have a proper step at this point.
    console.log 'LOADING STEP', step

    # Unload the current step.
    @unload @currentStep if @currentStep

    @el.addClass step.className

    # Wait a tick so any DOM changes can take place and the size of the dialog can be figured out.
    wait 25, =>
      @attach step.attachment

    # Fill in the new content.
    for stepPart in STEP_PARTS
      @[stepPart].html step[stepPart]?(@) || step[stepPart] || ''
      @[stepPart].addClass 'defined' if @[stepPart].html()

    isStep = step.next instanceof Step
    isPrimitive = typeof step.next in ['string', 'number', 'boolean']
    isFunction = typeof step.next is 'function'
    isntDefined = not step.next?

    # Auto-add a "next" button if the next step doesn't rely on an event.
    if isStep or isPrimitive or isFunction or isntDefined
      @buttons.html "<button name='next-step'>#{step.nextButton}</button>"
      @buttons.addClass 'defined'

    # Otherwise the next step is determined in response to an event.
    else
      for eventString, next of step.next then do (eventString, next) =>
        console.log 'on', eventString, next
        [eventName, selector...] = eventString.split /\s+/
        selector = selector.join ' '
        $document.on "#{eventName}.zootorial-#{@id}", selector, =>
          next = next @ if typeof next is 'function'
          console.log 'Reaction leads to', next
          @load next

    @createBlockers()

    @positionFocusers()

    $(step.actionable).addClass 'actionable'

    step.onEnter? @
    step.enter @

    @currentStep = step
    step

  createBlockers: ->
    # TODO: Copy from Step class

  positionFocusers: ->
    # TODO: Copy from Step class

  unload: ->
    return unless @currentStep

    @instruction.removeClass 'attention'

    @el.removeClass @currentStep.className

    for stepPart in STEP_PARTS
      @[stepPart].html ''
      @[stepPart].removeClass 'defined'

    $document.off ".zootorial-#{@id}"

    $(@currentStep.actionable).removeClass 'actionable'

    @currentStep.onExit? @
    @currentStep.exit @

  start: ->
    @close()
    @started = new Date
    @unload()
    @load @firstStep
    @open()
    @el.trigger 'start-tutorial', [@, @started]

  complete: ->
    finished = new Date - @started
    @el.trigger 'complete-tutorial', [@, finished]
    @end()

  end: ->
    finished = new Date - @started
    @started = null
    @close()
    @el.trigger 'end-tutorial', [@, finished]
