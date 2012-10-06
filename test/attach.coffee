attach = require '../lib/attach'

attachedThing = $('#attached-thing')
bigBox = $('#big-box')

describe 'attach', ->
  beforeEach ->
    $('html, body').css
      margin: 0
      overflow: 'hidden'

  afterEach ->
    $('html, body').css
      margin: ''
      overflow: ''

  it 'exists', ->
    expect(attach).toBeDefined()

  it 'centers the element if no other arguments are given', ->
    attach attachedThing
    offset = attachedThing.offset()
    height = attachedThing.height()
    width = attachedThing.width()
    expect(offset.left).toBe (window.innerWidth / 2) - (width / 2)
    expect(offset.top).toBe (window.innerHeight / 2) - (height / 2)

  it 'centers a specific point of the element if coordinates are given', ->
    attach attachedThing, ['left', 'top']
    offset = attachedThing.offset()
    height = attachedThing.height()
    width = attachedThing.width()
    expect(offset.left).toBe window.innerWidth / 2
    expect(offset.top).toBe window.innerHeight / 2

  it 'aligns a certain point of the element to the center of another', ->
    attach attachedThing, ['right', 'bottom'], to: bigBox
    offset = attachedThing.offset()
    height = attachedThing.height()
    width = attachedThing.width()
    targetOffset = bigBox.offset()
    targetWidth = bigBox.width()
    targetHeight = bigBox.height()
    expect(offset.left + width).toBe targetOffset.left + (targetWidth / 2)
    expect(offset.top + height).toBe targetOffset.top + (targetHeight / 2)

  it 'aligns a certain point of the element to a certain point of another', ->
    attach attachedThing, ['left', 'top'], to: bigBox, ['right', 'bottom']
    offset = attachedThing.offset()
    height = attachedThing.height()
    width = attachedThing.width()
    targetOffset = bigBox.offset()
    targetWidth = bigBox.width()
    targetHeight = bigBox.height()
    expect(offset.left).toBe targetOffset.left + targetWidth
    expect(offset.top).toBe targetOffset.top + targetHeight
