module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    cfg:
      cache:
        uncached:
          files: 'build/**/*.{html,txt,xml,svg}'
        normal:
          header: 'public,max-age=604800'
          files: 'build/**/*.{css,js,jpg,png}'
        extended:
          header: 'public,max-age=194400000'
          files: 'build/**/*.ico'
      deploy:
        config: 'aws-upload-staging.conf.js'
      wintersmith:
        config: 'config-preview.json'

    clean:
      build: ["build"]

    stylus:
      dist:
        options:
          paths: ["work/styles/stylus_modules"]
        files:
          "contents/css/main.css": "work/styles/main.styl"
      dev:
        options:
          paths: ["work/styles/**"]
        files:
          "contents/css/main.css": "work/styles/main.styl"

    imagemin:
      dist:
        options:
          optimizationLevel: 3

        files: [
          expand: true
          cwd: "build/"
          src: ["**/*.{jpg,png}"]
          dest: "build/"
          ext: ".jpg"
        ]

    coffee:
      compile: {
        files: {
          'contents/js/main.min.js': 'work/scripts/**/*.coffee'
        }
      }

    wintersmith:
      remote:
        options:
          config: "<%= cfg.wintersmith.config %>"
      preview:
        options:
          action: "preview"
          config: "./config-preview.json"

    bump:
      options:
        files: ["package.json"]
        updateConfigs: ['pkg']
        commit: true
        commitMessage: "Bump version to %VERSION%"
        commitFiles: ["package.json"] # '-a' for all files
        createTag: false
        tagName: "%VERSION%"
        tagMessage: "Version %VERSION%"
        push: false
        pushTo: "origin"
        # options to use with '$ git describe'
        gitDescribeOptions: "--tags --always --abbrev=1 --dirty=-d"

    shell:
      s3upload:
        command: [
          "cp <%= cfg.deploy.config %> build/aws-upload.conf.js"
          "cd build"
          "node ../node_modules/s3-upload/bin/s3-upload.js"
          "rm ./aws-upload.conf.js"
        ].join '&&'
        options:
          stdout: "true"
          failOnError: "true"
      githubDeploy:
        command: [
          "echo '<%= cfg.wintersmith.url %>' > ./build/CNAME"
          "cp ./.gitignore ./build"
          "cd ./build"
          "git init"
          "git add ."
          "git commit -m 'Deploy'"
          "git push 'git@github.com:wmayner/iit.github.io.git' master:master --force"
          "rm -rf .git"
        ].join '&&'
        options:
          stdout: "true"
          failOnError: "true"

    uglify:
      production:
        files:
          "build/js/main.min.js": "build/js/main.min.js"

    watch:
      js:
        files: ["work/scripts/**/*.coffee", "Gruntfile.coffee"]
        tasks: ["coffee:compile"]
      stylus:
        files: ["work/styles/**/*.styl"]
        tasks: ["stylus:dev"]

    lineremover:
      html:
        files: [
          expand: true
          cwd: "build/"
          src: ["**/*.html"]
          dest: "build/"
          ext: ".html"
        ]
      xml:
        files: [
          expand: true
          cwd: "build/"
          src: ["**/*.xml"]
          dest: "build/"
          ext: ".xml"
        ]

    cssmin:
      production:
        expand: true
        cwd: "build/css"
        src: ["*.css"]
        dest: "build/css"

  # Load NPM Tasks
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-imagemin"
  grunt.loadNpmTasks "grunt-contrib-stylus"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-shell"
  grunt.loadNpmTasks "grunt-line-remover"
  grunt.loadNpmTasks "grunt-contrib-cssmin"
  grunt.loadNpmTasks "grunt-wintersmith"
  grunt.loadNpmTasks "grunt-bump"

  # Grunt Custom Tasks
  grunt.registerTask "defineEnvironment",
    "A task to set config values per environment", (environment) ->
      if environment is "production"
        grunt.config.set "cfg.deploy.config", "aws-upload-production.conf.js"
        grunt.config.set "cfg.wintersmith.config", "config-production.json"
      if environment is "github"
        grunt.config.set "cfg.wintersmith.config", "config-github.json"

  # Grunt Tasks
  grunt.registerTask "dev", [
    "watch"
  ]
  grunt.registerTask "default", [
    "wintersmith:preview"
  ]
  grunt.registerTask "preview", [
    "wintersmith:preview"
  ]
  grunt.registerTask "prebuild", [
    "clean:build"
    "stylus:dist"
  ]
  grunt.registerTask "postbuild", [
    "lineremover"
    "imagemin:dist"
    "uglify:production"
    "cssmin:production"
  ]
  grunt.registerTask "buildStaging", [
    "defineEnvironment:staging"
    "prebuild"
    "wintersmith:remote"
    "postbuild"
  ]
  grunt.registerTask "buildProduction", [
    "defineEnvironment:production"
    "prebuild"
    "wintersmith:remote"
    "postbuild"
  ]
  grunt.registerTask "buildGithub", [
    "defineEnvironment:github"
    "prebuild"
    "wintersmith:remote"
    "postbuild"
  ]
  grunt.registerTask "deployStaging", [
    "buildStaging"
    "shell:s3upload"
  ]
  grunt.registerTask "deployGithub", [
    "buildGithub"
    "shell:githubDeploy"
  ]
  grunt.registerTask "deployProduction", [
    "buildProduction"
    "shell:s3upload"
  ]
