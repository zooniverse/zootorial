factory = ($, attach) ->
  underlay = $('<div class="hidden zootorial-underlay"></div>')
  underlay.appendTo 'body'

  class Dialog
    header: ''
    content: ''
    buttons: null
    attachment: null

    openImmediately: false
    destroyOnClose: false

    destructionDelay: 500
    attachmentDelay: 125

    el: null
    underlay: underlay

    constructor: (params = {}) ->
      @[property] = value for own property, value of params when property of @
      @buttons ||= []
      @attachment ||= to: null, at: {}

      @el ||= $("<div class='zootorial-dialog'></div>")
      @el = $(@el) unless @el instanceof $

      @el.html """
        <header></header>
        <div class="content"></div>
        <footer></footer>
      """

      @render()
      @el.appendTo 'body'

      @open() if @openImmediately

    render: ->
      header = @el.find('header').first()
      content = @el.find('.content').first()
      footer = @el.find('footer').last()

      texts = header: null, content: null
      for section in ['header', 'content']
        part = @[section]

        if typeof part is 'string'
          part = part.split '\n'

        if part instanceof Array
          part = $("<p>#{part.join '</p><p>'}</p>")

        texts[section] = part

      header.empty().append texts.header
      content.empty().append texts.content

      footer.empty()
      for button, i in @buttons
        if typeof button in ['string', 'number']
          button = $("<button data-index='#{i}'>#{button}</button>")
        else
          for key, value of button
            button = $("<button data-index='#{value}'>#{key}</button>")

        footer.append button

      @attach()

    attach: ->
      setTimeout @_attach, @attachmentDelay

    _attach: =>
      attach @el, [
        @attachment.x
        @attachment.y
      ], to: @attachment.to, [
        @attachment.at.x
        @attachment.at.y
      ]

    open: ->
      @underlay.removeClass 'hidden'
      @el.removeClass 'hidden'
      $(window).on 'resize', @_attach

    close: ->
      @underlay.addClass 'hidden'
      @el.addClass 'hidden'
      $(window).off 'resize', @_attach

      @destroy() if @destroyOnClose

    destroy: ->
      setTimeout @_destroy, @destructionDelay

    _destroy: =>
      @el.remove()

  Dialog

if define?.amd
  define ['jquery', './attach'], factory
else
  jQuery = window.jQuery
  attach = window.zootorial?.attach

  if module?.exports
    attach ?= require './attach'
    module.exports = factory jQuery, attach
  else
    window.zootorial ?= {}
    window.zootorial.Dialog = factory jQuery, attach
