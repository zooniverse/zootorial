attach = require '../lib/attach'

attachedThing = $('#attached-thing')
bigBox = $('#big-box')

leftOf = (el) -> $(el).offset().left
rightOf = (el) -> $(el).offset().left + $(el).width()
centerOf = (el) -> (leftOf(el) + rightOf(el)) / 2

topOf = (el) -> $(el).offset().top
bottomOf = (el) -> $(el).offset().top + $(el).height()
middleOf = (el) -> (topOf(el) + bottomOf(el)) / 2

describe 'attach', ->
  beforeEach ->
    $('html, body').css margin: 0, overflow: 'hidden'

  afterEach ->
    $('html, body').css margin: '', overflow: ''

  it 'exists', ->
    expect(attach).toBeDefined()

  it 'throws with no arguments', ->
    expect(-> attach()).toThrow()

  it 'centers the element if no other arguments are given', ->
    attach attachedThing
    expect(centerOf attachedThing).toBe window.innerWidth / 2
    expect(middleOf attachedThing).toBe window.innerHeight / 2

  it 'centers a specific point of the element if coordinates are given', ->
    attach attachedThing, ['left', 'top']
    expect(leftOf attachedThing).toBe window.innerWidth / 2
    expect(topOf attachedThing).toBe window.innerHeight / 2

  it 'aligns a certain point of the element to the center of another', ->
    attach attachedThing, ['right', 'bottom'], to: bigBox
    expect(rightOf attachedThing).toBe centerOf bigBox
    expect(bottomOf attachedThing).toBe middleOf bigBox

  it 'aligns a certain point of the element to a certain point of another', ->
    attach attachedThing, ['left', 'top'], to: bigBox, ['right', 'bottom']
    expect(leftOf attachedThing).toBe rightOf bigBox
    expect(topOf attachedThing).toBe bottomOf bigBox
