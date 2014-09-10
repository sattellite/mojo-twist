$(function() {

  /* Helper functions */
  jQuery.cachedScript = function(url, options) {
    options = $.extend( options || {}, {
      dataType: "script",
      cache: true,
      url: url
    });
    return jQuery.ajax( options );
  };

  jQuery.getStyle = function(url) {
    var cssLink = $("<link rel='stylesheet' type='text/css' href='"+url+"'>");
    $("head").append(cssLink);
  };

  var edit = $('button.edit'),
      scripts = [
        '/js/markdown.js',
        '/js/to-markdown.js',
        '/js/editor-markdown.js',
        '/js/jquery.hotkeys.js'
      ],
      styles = [
        '/css/styles.css',
        '/css/editor-markdown.css'
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

    // Replace <a id="cut"> with <hr>
    $('a#cut').replaceWith('<hr>');

    // Fix <pre><code>...</code></pre> for `to-markdown`
    $('pre').replaceWith(function(i, val){
      return val;
    });

    // Call editor
    $(".article-content").markdown();

    $.each(['edit', 'publish', 'remove'], function(){ $('.btn.'+this).hide() });
    $('div.white').append('<button class="btn cancel"><em class="icon-cancel"></em>Cancel</button>');

    var node1 = $('h1.title>a'),
        node2 = $('.article-meta'),
        title = node1.text().replace(/\r?\n.*/,''),
        day   = node2.clone().children().remove().end().text().replace(/.*\,\s(\d+).*/, '$1').replace(/\n|\s/g,''),
        date  = node1.attr('href').split('/').slice(2,4),
        tags  = node2.children().text().replace(/\s|\n/g, '').split(/,/);

    date.push(day);
    node1.parent().replaceWith(function(){
      return $('<input/>', { name: 'title', value: title, class: 'form-control', placeholder: 'Title'})
    });

    node2.replaceWith(function(){
      return [$('<input/>', { name: 'date', value: date.join('-'), class: 'form-control', placeholder: 'Date' }),
             $('<input/>', { name: 'tags', value: tags.join(', '), class: 'form-control', placeholder: 'Tags' })]
    });

    $('button.cancel').bind('click', function(){ window.location.reload() });
    $('button.save').bind('click', function(){
      console.log($('textarea.md-input').val());
    });
  });
  /* END Edit button */
});
