{spawn} = require 'child_process'

exec = (fullCommand) ->
  [command, args...] = fullCommand.split ' '
  child = spawn command, args
  child.stdout.on 'data', process.stdout.write.bind process.stdout
  child.stderr.on 'data', process.stderr.write.bind process.stderr

task 'watch', ->
  exec 'coffee --compile --output ./lib --watch ./src'
  exec 'stylus --out ./lib/css --watch ./src/css'

task 'serve', (options) ->
  invoke 'watch'
  exec "silver server --port #{process.env.PORT || 2007}"
