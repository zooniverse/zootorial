factory = ($) ->
  (el, [elX, elY] = [], elMargin = 0, to = '', [toX, toY] = [], toMargin = 0) ->
    el = $(el)
    throw new Error 'Couldn\'t find an element to attach.' if el.length is 0

    to = $(to).filter(':visible').first()
    to = $(window) if to.length is 0

    elX ?= 'center'
    elY ?= 'middle'
    toX ?= 'center'
    toY ?= 'middle'

    positions =
      left: 0, center: 0.5, right: 1
      top: 0, middle: 0.5, bottom: 1

    elX = positions[elX] if elX of positions
    toY = positions[toY] if toY of positions
    elY = positions[elY] if elY of positions
    toX = positions[toX] if toX of positions

    toSize =
      width: to.outerWidth() + (toMargin * 2)
      height: to.outerHeight() + (toMargin * 2)

    toOffset = to.offset() || left: 0, top: 0
    toOffset.top -= toMargin
    toOffset.left -= toMargin

    # window.toDebug ?= $('<div id="zootorial-to-debug"></div>')
    # window.toDebug.appendTo 'body'
    # window.toDebug.css outline: '2px solid red', pointerEvents: 'none', position: 'absolute', zIndex: 99
    # window.toDebug.width toSize.width
    # window.toDebug.height toSize.height
    # window.toDebug.offset toOffset

    elSize =
      width: el.outerWidth() + (elMargin * 2)
      height: el.outerHeight() + (elMargin * 2)

    newElOffset =
      left: (toOffset.left - (elSize.width * elX) + (toSize.width * toX)) + elMargin
      top: (toOffset.top - (elSize.height * elY) + (toSize.height * toY)) + elMargin

    # window.elDebug ?= $('<div id="zootorial-el-debug"></div>')
    # window.elDebug.appendTo 'body'
    # window.elDebug.css outline: '2px solid green', pointerEvents: 'none', position: 'absolute', zIndex: 99
    # window.elDebug.width elSize.width
    # window.elDebug.height elSize.height
    # window.elDebug.offset newElOffset

    el.offset newElOffset

if define?.amd
  define ['jquery'], factory
else
  jQuery = window.jQuery

  if module?.exports
    module.exports = factory jQuery
  else
    window.zootorial ?= {}
    window.zootorial.attach = factory jQuery
