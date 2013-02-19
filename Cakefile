{spawn} = require 'child_process'

exec = (fullCommand) ->
  [command, args...] = fullCommand.split ' '
  child = spawn command, args
  child.stdout.on 'data', process.stdout.write.bind process.stdout
  child.stderr.on 'data', process.stderr.write.bind process.stderr

coffee = [
  './src/utilities'
  './src/attach'
  './src/dialog'
  './src/step'
  './src/tutorial'
  './src/exports'
]

styl = [
  './src/css/zootorial.styl'
]

task 'watch', ->
  exec "coffee --watch --join ./zootorial.js --compile #{coffee.join ' '}"
  exec 'coffee --watch --output . --compile src/google-analytics.coffee'

  exec "stylus --out . --watch #{styl.join ' '}"

task 'serve', (options) ->
  invoke 'watch'
  exec "silver server --port #{process.env.PORT || 2007}"
