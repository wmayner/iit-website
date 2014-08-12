$(document).ready ->
  $(".iit-sidebar").affix offset:
    top: 160
    bottom: ->
      @bottom = $(".iit-footer").outerHeight(true)

