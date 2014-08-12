$(document).ready ->
  # Get the page we're on.
  page = location.pathname.split('/')[1]
  # Add the `active` class to the matching navlinks.
  $(".navbar a[href='/#{page}']").addClass 'active'
