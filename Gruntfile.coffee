module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    karma:
      unit:
        configFile: 'karma.conf.js'

    browserify:
      dist:
        files:
          'dist/really.js': ['src/really.coffee']


        options:
          transform: ['coffeeify']
          banner: """
          /*!
           *  Really.js v<%= pkg.version %>
           *  Copyright (C) 2014-2015 Really Inc. <http://really.io>
           *
           *  Date: <%= grunt.template.today() %>
           */
          """
          browserifyOptions:
            standalone: 'Really'

    uglify:
      options:
        preserveComments: 'some'
        compress:
          'drop_console': true
      dist:
        files:
          'dist/really.<%= pkg.version %>.min.js': 'dist/really.js'

    coffeelint:
      src: ['src/**/*.coffee']
      tests: ['tests/**/*.coffee']
      options:
        configFile: 'coffeelint.json'

  grunt.registerTask 'test', [
    'karma'
  ]


  grunt.registerTask 'build', [
    'coffeelint',
    'browserify:dist',
    'uglify:dist'
  ]


