module.exports = (grunt) ->
  grunt.initConfig

    pkg: grunt.file.readJSON 'package.json'

    watch:
      lib  :
        files: [
          'src/**/*.coffee'
        ]
        tasks: [ 'lib' ]

    coffeemill:
      lib:
        options:
          name  : 'easeljs.tm'
          js    : true
          coffee: true
          map   : true
          uglify: true

    release:
      options:
        file: 'bower.json'
        npm : false


  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-coffeemill'
  grunt.loadNpmTasks 'grunt-release'

  grunt.registerTask 'lib', [
    'coffeemill:lib'
  ]
  grunt.registerTask 'run', [
    'lib'
  ]
  grunt.registerTask 'default', [
    'run'
    'watch'
  ]