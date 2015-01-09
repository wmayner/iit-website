$(document).ready ->
  # Get the page we're on.
  page = location.pathname.split('/')[1]
  # Unless we're at the root, activate navlinks based on page name.
  unless page is ""
    $(".navbar a").removeClass 'active'
    $(".navbar a[href^='/#{page}']").addClass 'active'
