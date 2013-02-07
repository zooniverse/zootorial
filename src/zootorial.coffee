factory = (attach, Dialog, Step, Tutorial) ->
  {attach, Dialog, Step, Tutorial}

if define?.amd
  define ['./attach', './dialog', './step', './tutorial'], factory
else if module?.exports
  attach ?= require './attach'
  Dialog ?= require './dialog'
  Step ?= require './step'
  Tutorial ?= require './tutorial'
  module.exports = factory attach, Dialog, Step, Tutorial
