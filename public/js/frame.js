$(function() {
  /* Helper functions */
  $.cachedScript = function(url, options) {
    options = $.extend( options || {}, {
      dataType: "script",
      cache: true,
      url: url
    });
    return $.ajax( options );
  };

  $.getStyle = function(url) {
    var cssLink = $("<link rel='stylesheet' type='text/css' href='"+url+"'>");
    $("head").append(cssLink);
  };

  var edit = $('button.edit'),
      scripts = [
        '/js/editor.js',
        '/js/jquery.hotkeys.js'
      ],
      styles = [
        '/css/styles.css'
      ];
  // Add scripts and styles
  $.each(scripts, function(i, val){
    $.cachedScript(val);
  });
  $.each(styles, function(i, val){
    $.getStyle(val);
  });

  /* Init Lazyload */
  $(".container img").lazyload({
    skip_invisible : false,
    effect: "fadeIn"
  });
  /* END Init Lazyload */

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

  /* Edit button */
  var edit = $('button.edit');//,
  edit.bind('click', function(e){
    var ed = new Editor;
  });
  /* END Edit button */
});
