factory = (attach, Dialog, Tutorial) ->
  {attach, Dialog, Tutorial}

if define?.amd
  define ['./attach', './dialog', './tutorial'], factory
else
  attach = window.zootorial?.attach
  Dialog = window.zootorial?.Dialog
  Tutorial = window.zootorial?.Tutorial

  if module?.exports
    attach ?= require './attach'
    Dialog ?= require './dialog'
    Tutorial ?= require './tutorial'
    module.exports = factory attach, Dialog, Tutorial
  else
    window.zootorial ?= {}
    window.zootorial = factory attach, Dialog, Tutorial
