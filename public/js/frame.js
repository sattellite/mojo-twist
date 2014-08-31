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

  var parent = window.parent,
      frame  = parent.document.getElementById('frame');

  /* Publish button */
  var publish = $('button.publish');
  publish.bind('click', function(e){
    $.post(publish.attr('data-url'), function(){})
      .done(function(){
        frame.setAttribute("src", "about:blank");
        var m = publish.attr('data-find');
        parent.$('.articles-list a').each(function(){
          if ( $(this).attr('data-src') == m ) {
            $(this).parent().remove();
            return false; // Stop loop if matched
          }
        });
      });
  });
  /* END Publish button */

  /* Hide button */
  var hide = $('button.hide');
  hide.bind('click', function(e){
    $.post(hide.attr('data-url'), function(){})
      .done(function(){
        frame.setAttribute("src", "about:blank");
        var m = hide.attr('data-find');
        parent.$('.articles-list a').each(function(){
          if ( $(this).attr('data-src') == m ) {
            $(this).parent().remove();
            return false; // Stop loop if matched
          }
        });
      });
  });
  /* END Hide button */

  /* Remove button */
  var remove = $('button.remove');
  remove.bind('click', function(e){
    $.post(remove.attr('data-url'), function(){})
      .done(function(){
        frame.setAttribute("src", "about:blank");
        var m = remove.attr('data-find');
        parent.$('.articles-list a').each(function(){
          if ( $(this).attr('data-src') == m ) {
            $(this).parent().remove();
            return false; // Stop loop if matched
          }
        });
      });
  });
  /* END Remove button */

});
