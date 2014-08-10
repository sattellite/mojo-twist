$(function() {
  /* Async load CSS */
  $("head").append('<link rel="stylesheet" href="/css/styles.css" type="text/css">');
  /* END Async load CSS */

  /* Init Lazyload */
  $(".container img").lazyload({
    skip_invisible : false,
    effect: "fadeIn"
  });
  /* END Init Lazyload */

  /* Append class for prettyprint */
  var editors = [];
  $('.article-content > pre').each(function() {
      $(this).addClass("prettyprint");
  });
  /* END Append class for prettyprint */

  /* Helper for active page */
  function stripTrailingSlash(str) {
    if(str.substr(-1) == '/') {
      return str.substr(0, str.length - 1);
    }
    return str;
  }
  /* END Helper for active page */

  /* Set class "active" in navigation menu for active page */
  var url = window.location.pathname;
  var activePage = stripTrailingSlash(url);

  $('header nav li a').each(function(){
    if ($(this).attr('href')) {
      var currentPage = stripTrailingSlash($(this).attr('href'));
    }
    if (activePage == currentPage) {
      $(this).addClass('active');
    }
  });
  /* END Set class "active" in navigation menu for active page */

  /* Button to top */
  if (window.location.pathname != '/edit') {
    var popup = $('<div class="popup hiding">»</div>');
    $('body').append(popup);

    $('.container').waypoint(function(direction) {
      $('.popup').toggleClass('hiding', direction === "up");
    }, {
      offset: function() {
        return -$.waypoints('viewportHeight')/2;
      }
    });
  }
  /* END Button to top */

  /* Event for click on button */
  $('.popup').bind('click' , function(event){
    $('body,html').stop(true,true).animate({scrollTop:240}, 700);
  });
  /* END Event for click on button */

  /* Fixing articles-list height */
  if (window.location.pathname == '/edit') {
    var selector = '.articles-list ul';
    if ($(selector).length) {
      $(selector).css('max-height', $(window).height() - $('footer').height() );
      $(window).resize(function(){$(selector).css('max-height', $(window).height() - $('footer').height() );});
    }
  }
  /* END fixing articles-list height */
});
