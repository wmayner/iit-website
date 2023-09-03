updateNavlinks = ->
  # Get the page/hash we're on.
  page = window.location.pathname.split('/')[1]
  hash = window.location.hash
  # Unless we're at the root, activate navlinks based on page and hash.
  unless page is ""
    $(".navbar a").removeClass 'active'
    if hash is ""
      $(".navbar a[href^='/#{page}']").addClass 'active'
    else
      $(".navbar a[href^='/#{page}#{hash}']").addClass 'active'

$(document).ready(updateNavlinks)
window.onhashchange = updateNavlinks
