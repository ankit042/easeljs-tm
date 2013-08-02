{ spawn } = require 'child_process'

option '-o', '--output [filename]', 'Additional output path'

task 'uglify', 'compile with coffeemill', ({output}) ->
  outputs = [ 'lib' ]
  outputs.push output if output?
  coffeemill = spawn '../coffeemill/bin/coffeemill', [
    '-i', 'src'
    '-o', outputs.join(',')
    '-n', 'easeljs.tm'
    '-wu'
  ],
    stdio: 'inherit'

task 'full', 'compile with coffeemill', ({output}) ->
  outputs = [ 'lib' ]
  outputs.push output if output?
  coffeemill = spawn 'coffeemill', [
    '-i', 'src'
    '-o', outputs.join(',')
    '-n', 'easeljs.tm'
    '-wjcmu'
  ],
    stdio: 'inherit'
