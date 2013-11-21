class Tutorial
  steps: null
  first: 'first'

  parent: document.body

  # Defaults, overrideable per-step
  demoLabel: 'Show me'
  nextLabel: 'Continue'
  doneLabel: 'Done'
  attachment: [0.5, 0.5, window, 0.5, 0.5]

  _current: null

  namedPoints:
    top: 0, middle: 0.5, bottom: 1
    left: 0, center: 0.5, right: 1

  # Set this to null if you'd prefer to use absolute left and top.
  transformProperty: if 'transform' of document.body.style
    'transform'
  else if 'mozTransform' of document.body.style
    '-moz-transform'
  else if 'msTransform' of document.body.style
    '-ms-transform'
  else if 'webkitTransform' of document.body.style
    '-webkit-transform'

  constructor: (params = {}) ->
    @[property] = value for property, value of params
    @steps ?= {}

    @container = @createElement 'div.zootorial-container'
    @el = @createElement 'div.zootorial-tutorial', @container
    @header = @createElement 'header.zootorial-header', @el
    @content = @createElement 'div.zootorial-content', @el
    @instruction = @createElement 'div.zootorial-instruction', @el
    @footer = @createElement 'footer.zootorial-footer', @el

    @delegatedEventListeners = []

    @blockers = []
    @focusers = []
    @actionables = []

    @parent.appendChild @container

    @attach() # Set a decent initial position.

    @end()

  createElement: (tagAndClassNames, parent) ->
    [tag, classNames...] = tagAndClassNames.split '.'
    el = document.createElement tag
    el.className = classNames.join ' '
    parent.appendChild el if parent?
    el

  start: ->
    @onBeforeStart?()
    @el.style.opacity = 0
    @el.style.display = ''
    @goTo @first
    @el.style.opacity = ''
    @onStart?()

  end: ->
    @onBeforeEnd?()
    @unloadCurrentStep()
    @el.style.display = 'none'
    @onEnd?()

  goTo: (step) ->
    if typeof step is 'function'
      step = step.call @

    if step?
      if typeof step is 'string'
        @unloadCurrentStep()
        @loadStep @steps[step]

      else if step is false
        times = parseFloat @instruction.getAttribute 'data-zootorial-attention'
        @instruction.setAttribute 'data-zootorial-attention', (times || 0) + 1

    else
      @end()

  loadStep: (@_current) ->
    @onBeforeLoadStep?()
    @_current.onBeforeLoad?.call @

    for section in ['header', 'content', 'instruction']
      if @_current?[section]?
        @[section].innerHTML = @_current[section]
      else
        @[section].style.display = 'none'

    if @_current.demo?
      demoButton = @createElement 'button.zootorial-demo', @instruction
      demoButton.innerHTML = @_current.demoLabel || @demoLabel
      demoButton.onclick = => @_current.demo.call @, arguments...

    if @_current.next?
      if typeof @_current.next in ['string', 'function']
        nextButton = @createElement 'button.zootorial-next', @footer
        nextButton.innerHTML = @_current.nextLabel || @nextLabel
        nextButton.onclick = => @goTo @_current.next

      else
        for eventNameAndSelector, nextStep of @_current.next
          [eventName, selector...] = eventNameAndSelector.split /\s+/
          selector = selector.join(' ') || '*'

          do (eventName, selector, nextStep) =>
            delegatedHandler = (e) =>
              selection = document.querySelectorAll selector

              target = e.target
              while target?
                target = if target in selection
                  @goTo nextStep
                  null
                else
                  target.parentNode

            setTimeout =>
              @delegatedEventListeners.push [eventName, delegatedHandler]
              addEventListener eventName, delegatedHandler, false

    else
      doneButton = @createElement 'button.zootorial-next.zootorial-done', @footer
      doneButton.innerHTML = @_current.doneLabel || @doneLabel
      doneButton.onclick = => @goTo null

    @attach() unless @_current.attachment is false

    @doToElements @_current.block, @block if @_current.block
    @doToElements @_current.focus, @focus if @_current.focus?
    @doToElements @_current.actionable, @actionable if @_current.actionable

    @_current.onLoad?.call @
    @onLoadStep?()

  attach: ->
    attachment = @_current?.attachment || @attachment
    # Why's this need to run twice? I don't know!
    @attachTo @el, attachment...
    @attachTo @el, attachment...

  setPosition: (el, left, top) ->
    offsetParent = el.offsetParent

    if offsetParent? and getComputedStyle(offsetParent).position is 'static'
      offsetParent = null

    [parentLeft, parentTop] = if offsetParent?
      parentRect = offsetParent.getBoundingClientRect()
      [parentRect.left + pageXOffset, parentRect.top + pageYOffset]
    else
      [0, 0]

    left -= parentLeft
    top -= parentTop

    if @transformProperty?
      el.style[@transformProperty] = "translate(#{Math.floor left}px, #{Math.floor top}px)"
    else
      el.style.position = 'absolute'
      el.style.left = "#{Math.floor left}px"
      el.style.top = "#{Math.floor top}px"

  attachTo: (el, eX, eY, target = window, tX, tY) ->
    el = document.querySelector el if typeof el is 'string'
    target = document.querySelector target if typeof target is 'string'

    eX = @namedPoints[eX] if eX of @namedPoints; eX = parseFloat eX
    eY = @namedPoints[eY] if eY of @namedPoints; eY = parseFloat eY
    tX = @namedPoints[tX] if tX of @namedPoints; tX = parseFloat tX
    tY = @namedPoints[tY] if tY of @namedPoints; tY = parseFloat tY

    if target is window
      targetLeft = pageXOffset
      targetTop = pageYOffset
      # NOTE: clientWidth/Height here return the viewport size minus scrollbars.
      targetWidth = document.documentElement.clientWidth
      targetHeight = document.documentElement.clientHeight
    else
      {left: targetLeft, top: targetTop} = target.getBoundingClientRect()
      targetLeft += pageXOffset
      targetTop += pageYOffset
      targetWidth = target.offsetWidth
      targetHeight = target.offsetHeight

    left = targetLeft + (tX * targetWidth) - (eX * el.offsetWidth)
    top = targetTop + (tY * targetHeight) - (eY * el.offsetHeight)

    @setPosition el, left, top
    [left, top]

  doToElements: (elOrElsOrSelector = [], fn, context) ->
    if elOrElsOrSelector instanceof HTMLElement
      elOrElsOrSelector = [elOrElsOrSelector]

    else if typeof elOrElsOrSelector is 'string'
      elOrElsOrSelector = document.querySelectorAll elOrElsOrSelector

    if elOrElsOrSelector instanceof NodeList
      elOrElsOrSelector = Array::slice.call elOrElsOrSelector

    elOrElsOrSelector.forEach fn, context || @

  block: (target) ->
    containerRect = @container.getBoundingClientRect()
    targetRect = target.getBoundingClientRect()

    blocker = @createElement 'div.zootorial-blocker', @container
    blocker.style.left = "#{(targetRect.left + pageXOffset) - containerRect.left}px"
    blocker.style.top = "#{(targetRect.top + pageYOffset) - containerRect.top}px"
    blocker.style.width = "#{target.offsetWidth}px"
    blocker.style.height = "#{target.offsetHeight}px"
    @blockers.push blocker

  focus: (target) ->
    html = document.documentElement
    containerRect = @container.getBoundingClientRect()
    targetRect = target.getBoundingClientRect()

    htmlWidth = Math.max html.clientWidth, html.offsetWidth
    htmlHeight = Math.max html.clientHeight, html.offsetHeight

    top = @createElement 'div.top.zootorial-focuser', @container
    top.style.left = "#{-containerRect.left - pageXOffset}px"
    top.style.top = "#{-containerRect.top - pageYOffset}px"
    top.style.width = "#{pageXOffset + htmlWidth}px"
    top.style.height = "#{targetRect.top + pageYOffset}px"

    right = @createElement 'div.right.zootorial-focuser', @container
    right.style.left = "#{targetRect.right - containerRect.left}px"
    right.style.top = "#{targetRect.top - containerRect.top}px"
    right.style.width = "#{htmlWidth - (targetRect.left + target.offsetWidth)}px"
    right.style.height = "#{target.offsetHeight}px"

    bottom = @createElement 'div.bottom.zootorial-focuser', @container
    bottom.style.left = "#{-containerRect.left - pageXOffset}px"
    bottom.style.top = "#{-containerRect.top + targetRect.bottom}px"
    bottom.style.width = "#{pageXOffset + htmlWidth}px"
    bottom.style.height = "#{htmlHeight - (targetRect.bottom + pageYOffset)}px"

    left = @createElement 'div.left.zootorial-focuser', @container
    left.style.left = "#{-containerRect.left - pageXOffset}px"
    left.style.top = "#{-containerRect.top + targetRect.top}px"
    left.style.width = "#{targetRect.left + pageXOffset}px"
    left.style.height = "#{target.offsetHeight}px"

    @focusers.push top, right, bottom, left

  actionable: (target) ->
    target.setAttribute 'data-zootorial-actionable', true
    @actionables.push target

  unloadCurrentStep: ->
    if @_current?
      @onBeforeUnloadStep?()
      @_current.onBeforeUnload?.call @

      for section in ['header', 'content', 'instruction', 'footer']
        until @[section].childNodes.length is 0
          @[section].removeChild @[section].childNodes[0]

        @[section].style.display = ''

      until @delegatedEventListeners.length is 0
        [eventName, delegatedHandler] = @delegatedEventListeners.shift()
        removeEventListener eventName, delegatedHandler, false

      until @blockers.length is 0
        blocker = @blockers.shift()
        blocker.parentNode.removeChild blocker

      until @focusers.length is 0
        focuser = @focusers.shift()
        focuser.parentNode.removeChild focuser

      until @actionables.length is 0
        @actionables.shift().removeAttribute 'data-zootorial-actionable'

      @instruction.removeAttribute 'data-zootorial-attention'

      @_current.onUnload?()
      @onUnloadStep?()

    @_current = null

  destroy: ->
    @onBeforeDestroy?()
    @end()
    @onDestroy?()

document.body.insertAdjacentHTML 'afterBegin', '''
  <div id="zootorial-temp" style="display: none;">
    <style class="zootorial-defaults">
      .zootorial-container {
        left: 0;
        position: absolute;
        top: 0;
        width: 100%;
      }

      .zootorial-tutorial {
        background: #ccc;
        color: #333;
        left: 0;
        position: absolute;
        top: 0;
        z-index: 1;
      }

      .zootorial-blocker {
        background: rgba(255, 0, 0, 0.1);
        cursor: not-allowed;
        position: absolute;
      }

      .zootorial-focuser {
        background: rgba(0, 0, 0, 0.5);
        position: absolute;
      }

      [data-zootorial-actionable] {}

      [data-zootorial-attention] {}
    </style>
  </div>
'''

tempDiv = document.getElementById 'zootorial-temp'
tempDiv.parentNode.insertBefore tempDiv.children[0], tempDiv
tempDiv.parentNode.removeChild tempDiv

zootorial = {Tutorial}
window.zootorial = zootorial
module?.exports = zootorial
