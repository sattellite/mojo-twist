$(function() {

  "use strict";

  Number.prototype.leadZero = Number.prototype.leadZero ||
  function(base){
    var nr = this, len = (String(base).length - String(nr).length)+1;
    return len > 0 ? new Array(len).join('0')+nr : nr;
  };

  var Editor = function() {
    this.$textarea = null;
    this.$preview  = false;
    this.$nextTab  = [];
    this.$inputs   = [];
    this.$loader   = [];
    this.$lazyload = function() { $('.container img').lazyload({ skip_invisible : false, effect: "fadeIn" }) };

    this.showEditor();
  };

  Editor.prototype = {

    _defer: function(ajax_act, elem) {
      this.__preload(elem);
      var d = $.when(ajax_act);
      return d;
    },

    __preload: function(elem) {
      var el      = $(elem),
          body    = $('body'),
          pos     = el.offset() ? el.offset() : {top: 0, left: 0},
          el_h    = el.height(),
          el_w    = el.width(),
          loader  = $('<div/>', {class:'loader'}).append($('<img>', {src : '/loader.gif'})),
          overlay = $('<div/>', {class:'overlay'}).css({ position:'fixed', top: pos.top, left: pos.left, background: '#5A3EB6', opacity: 0.3, 'z-index': 999, width: el_w, height: el_h });
      loader.css({ position:'fixed', 'z-index': 1000, top: pos.top + ((el_h-28)/2), left: pos.left + ((el_w-28)/2) });

      this.$loader.push(overlay, loader);

      body.append(overlay);
      body.append(loader);
      $(elem).resize(function(){
        var pos = el.offset() ? el.offset() : {top: 0, left: 0};
        loader.css({ top: pos.top + ((el.height()-28)/2), left: pos.left + ((el.width()-28)/2) });
        overlay.css({ width: el.width(), height: el.height() });
      });
    },

    __clearPreload: function() {
      for (var i in this.$loader) {
        this.$loader[i].remove();
        this.$loader[i].off('resize');
      }
      this.$loader = [];
    },

    __editorBtns: function() {
      var btn_cancel = $('<button/>', { class : 'btn cancel'}).text('Cancel').prepend($('<em/>', { class : 'icon-cancel' })),
          btn_save   = $('<button/>', { class : 'btn save'}).text('Save').prepend($('<em/>', { class : 'icon-save' })),
          parent     = $('div.white'),
          t          = this;

      $.each(['edit', 'publish', 'remove'], function(){ $('.btn.'+this).remove() });
      parent.append(btn_cancel);
      parent.prepend(btn_save);

      btn_cancel.click(function(){ window.location.reload() });
      btn_save.click(function(){ t._saveHandler() });
    },

    __getMarkdown: function(elem) {
      var result = null,
          url    = window.location+'.json';

      var d = this._defer($.ajax({
        url: url,
        dataType: 'json',
      }), elem);
      return d;
    },

    showEditor: function() {
      var that = this;
      this.__getMarkdown(window).done( function(data) {

        that.__clearPreload();
        that.__editorBtns();
        var data    = data.article,
            slug    = data.slug,
            tags    = data.tags,
            title   = data.title,
            content = data.content,
            date    = new Date(data.date*1000),
            datef   = date.getFullYear()+'-'+(date.getMonth()+1).leadZero(10)+'-'+(date.getDate()).leadZero(10);

        var btn_preview = $('<button/>', { type: 'button', class: 'btn preview', title: 'Preview (Ctrl+P)', tabindex: -1, 'data-hotkey': 'Ctrl+P' }).append($('<span/>', { class: 'icon-search' }).text('Preview')),
            btn_bold    = $('<button/>', { type: 'button', class: 'btn', title: 'Bold (Ctrl+B)',    tabindex: -1, 'data-hotkey': 'Ctrl+B' }).append($('<span/>', { class: 'icon-bold' })),
            btn_italic  = $('<button/>', { type: 'button', class: 'btn', title: 'Italic (Ctrl+I)',  tabindex: -1, 'data-hotkey': 'Ctrl+I' }).append($('<span/>', { class: 'icon-italic' })),
            btn_header  = $('<button/>', { type: 'button', class: 'btn', title: 'Heading (Ctrl+H)', tabindex: -1, 'data-hotkey': 'Ctrl+H' }).append($('<span/>', { class: 'icon-header' })),
            btn_link    = $('<button/>', { type: 'button', class: 'btn', title: 'URL/Link (Ctrl+L)', tabindex: -1, 'data-hotkey': 'Ctrl+L' }).append($('<span/>', { class: 'icon-link' })),
            btn_image   = $('<button/>', { type: 'button', class: 'btn', title: 'Image (Ctrl+G)', tabindex: -1, 'data-hotkey': 'Ctrl+G' }).append($('<span/>', { class: 'icon-image' })),
            btn_ulist   = $('<button/>', { type: 'button', class: 'btn', title: 'Unordered List (Ctrl+U)', tabindex: -1, 'data-hotkey': 'Ctrl+U' }).append($('<span/>', { class: 'icon-unordered' })),
            btn_olist   = $('<button/>', { type: 'button', class: 'btn', title: 'Ordered List (Ctrl+O)', tabindex: -1, 'data-hotkey': 'Ctrl+O' }).append($('<span/>', { class: 'icon-ordered' })),
            btn_code    = $('<button/>', { type: 'button', class: 'btn', title: 'Code (Ctrl+K)', tabindex: -1, 'data-hotkey': 'Ctrl+K' }).append($('<span/>', { class: 'icon-code' })),
            btn_quote   = $('<button/>', { type: 'button', class: 'btn', title: 'Quote (Ctrl+Q)', tabindex: -1, 'data-hotkey': 'Ctrl+Q' }).append($('<span/>', { class: 'icon-quote' })),
            btn_cut     = $('<button/>', { type: 'button', class: 'btn', title: 'Cut (Ctrl+M)', tabindex: -1, 'data-hotkey': 'Ctrl+M' }).append($('<span/>', { class: 'icon-cut' })),
            ta_rows     = parseInt(($(window).height() - 260)/(14*1.14), 10),
            textarea    = $('<textarea/>', { class: 'md-input', rows: ta_rows, style: 'resize: none', name: 'content' }),
            input_title = $('<input/>', { name: 'title', class: 'form-control', placeholder: 'Title', value: title }),
            input_date  = $('<input/>', { name: 'date',  class: 'form-control', placeholder: 'Date' , value: datef  }),
            input_slug  = $('<input/>', { name: 'slug',  class: 'form-control', placeholder: 'Slug' , value: slug  }),
            input_oslug = $('<input/>', { name: 'oldslug',class: 'form-control', type: 'hidden' , value: slug  }),
            input_tags  = $('<input/>', { name: 'tags',  class: 'form-control', placeholder: 'Tags' , value: tags  });

        that.$inputs.push( input_title, input_date, input_slug, input_oslug, input_tags, textarea );

        var editorArea = function() {

          return $('<article/>').append([ input_title, input_date, input_slug, input_tags,
            $('<div/>', { class: 'md-editor' }).append([
              $('<div/>', { class: 'md-header btn-toolbar'}).append([
                $('<div/>', { class: 'btn-group' }).append([ btn_bold, btn_italic, btn_header ]),
                $('<div/>', { class: 'btn-group' }).append([ btn_link, btn_image ]),
                $('<div/>', { class: 'btn-group' }).append([ btn_ulist, btn_olist, btn_code, btn_quote ]),
                $('<div/>', { class: 'btn-group' }).append( btn_cut ),
                $('<div/>', { class: 'btn-group' }).append( btn_preview )
              ]),
              textarea.val(content),
              $('<div/>', { class: 'md-footer' })
            ])
          ])
        };
        $('article').replaceWith(editorArea);

        that.$textarea = textarea;
        that.__buttonsListner({preview : btn_preview, image : btn_image, cut: btn_cut,
                               bold    : btn_bold   , ulist : btn_ulist,
                               italic  : btn_italic , olist : btn_olist,
                               header  : btn_header , code  : btn_code,
                               link    : btn_link   , quote : btn_quote});
      });
    },

    getSelection: function() {
      var e = this.$textarea[0];

      return (
        ('selectionStart' in e && function() {
            var l = e.selectionEnd - e.selectionStart;
            return { start: e.selectionStart, end: e.selectionEnd, length: l, text: e.value.substr(e.selectionStart, l) }
        }) ||
        /* browser not supported */
        function() {
          return null
        }
      )()
    },

    getContent: function() {
      return this.$textarea.val()
    },

    setSelection: function(start,end) {
      var e = this.$textarea[0];

      return (
          ('selectionStart' in e && function() {
              e.selectionStart = start;
              e.selectionEnd = end;
              return
          }) ||
          /* browser not supported */
          function() { return null }
      )()

    },

    replaceSelection: function(text) {
      var e = this.$textarea[0]

      return (
          ('selectionStart' in e && function() {
              e.value = e.value.substr(0, e.selectionStart) + text + e.value.substr(e.selectionEnd, e.value.length)
              e.selectionStart = e.value.length
              return this
          }) ||
          /* browser not supported */
          function() {
              e.value += text
              return $(e)
          }
      )()
    },

    setNextTab: function(start) {
      var that = this
      this.$nextTab.push(function(){
        return that.findSelection(start)
      })
    },

    findSelection: function(chunk) {
      var content = this.getContent(), startChunkPosition

      if (startChunkPosition = content.indexOf(chunk), startChunkPosition >= 0 && chunk.length > 0) {
        var oldSelection = this.getSelection(), selection

        this.setSelection(startChunkPosition,startChunkPosition+chunk.length)
        selection = this.getSelection()

        this.setSelection(oldSelection.start,oldSelection.end)

        return selection
      } else {
        return null
      }
    },

    showPreview: function(data, btns) {
      var e = this.$textarea;
      if (this.$preview) {
        $('.md-preview').remove();
        for (var k in btns){
          if (btns.hasOwnProperty(k) && k !== 'preview') {
            btns[k].removeAttr("disabled");
          }
        }
        e.show();
        this.$preview = false;
      }
      else {
        this.$preview = true;
        var height = e.height()+2,
            p = $('<div/>', {class: 'md-preview', height: height, width: '100%'}).append(data.html);
        for (var k in btns){
          if (btns.hasOwnProperty(k) && k !== 'preview') {
            btns[k].attr("disabled", "disabled");
          }
        }
        e.hide();
        e.after(p);
        this.$lazyload();
      }
    },

    __buttonsListner: function(b) {
      var t = this;
      b.preview && t._previewHandler(b);
      b.bold && b.bold.click(function(){ t._boldHandler(b.bold) });
      b.italic && b.italic.click(function(){ t._italicHandler(b.italic) });
      b.header && b.header.click(function(){ t._headerHandler(b.header) });
      b.link && b.link.click(function(){ t._linkHandler(b.link) });
      b.image && b.image.click(function(){ t._imageHandler(b.image) });
      b.ulist && b.ulist.click(function(){ t._ulistHandler(b.ulist) });
      b.olist && b.olist.click(function(){ t._olistHandler(b.olist) });
      b.code && b.code.click(function(){ t._codeHandler(b.code) });
      b.quote && b.quote.click(function(){ t._quoteHandler(b.quote) });
      b.cut && b.cut.click(function(){ t._cutHandler(b.cut) });
    },

    _previewHandler: function(e) {
      var t = this.$textarea, that = this, r = null;
      e.preview.bind('click', function(){
        if (!that.$preview) {
          that._defer($.ajax({
            type: 'POST',
            url: '/edit/prerender',
            data: t.serialize()
          }), t).done(function(data){
            r=data;
            that.__clearPreload();
            that.showPreview(r,e);
          });
        } else {
          that.showPreview(r,e);
        }
      });
    },

    _saveHandler: function() {
      var t = this,
          toSend = {};
      for (var i in t.$inputs) {
        toSend[t.$inputs[i].attr('name')] = t.$inputs[i].val();
      }
      $.ajax({
        type: 'POST',
        url: '/edit/save',
        data: $.param(toSend),
        async: false
      }).done(function(data){
        window.location.reload()
      });
    },

    _boldHandler: function() {
      var e = this, chunk, cursor, selected = e.getSelection(), content = e.getContent();

      if (selected.length == 0) {
        chunk = 'strong text';
      } else {
        chunk = selected.text;
      }

      if (content.substr(selected.start-2,2) == '**'
          && content.substr(selected.end,2) == '**' ) {
        e.setSelection(selected.start-2,selected.end+2);
        e.replaceSelection(chunk);
        cursor = selected.start-2;
      } else {
        e.replaceSelection('**'+chunk+'**');
        cursor = selected.start+2;
      }
      e.setSelection(cursor,cursor+chunk.length);
    },

    _italicHandler: function() {
      var e = this, chunk, cursor, selected = e.getSelection(), content = e.getContent();

      if (selected.length == 0) {
        chunk = 'emphasized text';
      } else {
        chunk = selected.text;
      }

      // transform selection and set the cursor into chunked text
      if (content.substr(selected.start-1,1) == '*'
          && content.substr(selected.end,1) == '*' ) {
        e.setSelection(selected.start-1,selected.end+1);
        e.replaceSelection(chunk);
        cursor = selected.start-1;
      } else {
        e.replaceSelection('*'+chunk+'*');
        cursor = selected.start+1;
      }
      e.setSelection(cursor,cursor+chunk.length);
    },

    _headerHandler: function(){
      var e = this, chunk, cursor, selected = e.getSelection(), content = e.getContent(), pointer, prevChar;

      if (selected.length == 0) {
        chunk = 'heading text';
      } else {
        chunk = selected.text + '\n';
      }

      if ((pointer = 4, content.substr(selected.start-pointer,pointer) == '### ')
          || (pointer = 3, content.substr(selected.start-pointer,pointer) == '###')) {
        e.setSelection(selected.start-pointer,selected.end);
        e.replaceSelection(chunk);
        cursor = selected.start-pointer;
      } else if (selected.start > 0 && (prevChar = content.substr(selected.start-1,1), !!prevChar && prevChar != '\n')) {
        e.replaceSelection('\n\n### '+chunk);
        cursor = selected.start+6;
      } else {
        e.replaceSelection('### '+chunk);
        cursor = selected.start+4;
      }
      e.setSelection(cursor,cursor+chunk.length);
    },

    _cutHandler: function() {
      var e = this, chunk, cursor, selected = e.getSelection();

      if (selected.length == 0) {
        chunk = 'enter cut text here';
      } else {
        chunk = selected.text;
      }
      e.replaceSelection('\n[cut] '+chunk+'\n');
      cursor = selected.start+7;
      e.setSelection(cursor,cursor+chunk.length);
    },

    _linkHandler: function () {
      var e = this, chunk, cursor, selected = e.getSelection(), content = e.getContent(), link;

      if (selected.length == 0) {
        chunk = 'enter link description here';
      } else {
        chunk = selected.text;
      }

      link = prompt('Insert Hyperlink','http://');

      if (link != null && link != '' && link != 'http://') {
        e.replaceSelection('['+chunk+']('+link+')');
        cursor = selected.start+1;
        e.setSelection(cursor,cursor+chunk.length);
      }
    },

    _imageHandler: function(){
      var e = this, chunk, cursor, selected = e.getSelection(), content = e.getContent(), link;

      if (selected.length == 0) {
        chunk = 'enter image description here';
      } else {
        chunk = selected.text;
      }

      link = prompt('Insert Image Hyperlink','http://');

      if (link != null) {
        e.replaceSelection('!['+chunk+']('+link+' "'+'enter image title here'+'")');
        cursor = selected.start+2;
        e.setNextTab('enter image title here');
        e.setSelection(cursor,cursor+chunk.length);
      }
    },
    _quoteHandler: function(){
      var e = this, chunk, cursor, selected = e.getSelection(), content = e.getContent();

      if (selected.length == 0) {
        chunk = 'quote here';
        e.replaceSelection('> '+chunk);
        cursor = selected.start+2;

      } else {
        if (selected.text.indexOf('\n') < 0) {
          chunk = selected.text;
          e.replaceSelection('> '+chunk);
          cursor = selected.start+2;
        } else {
          var list = [];

          list = selected.text.split('\n');
          chunk = list[0];

          $.each(list,function(k,v) {
            list[k] = '> '+v;
          })

          e.replaceSelection('\n\n'+list.join('\n'));
          cursor = selected.start+4;
        }
      }
      e.setSelection(cursor,cursor+chunk.length)
    },
    _codeHandler: function(){
      var e = this, chunk, cursor, selected = e.getSelection(), content = e.getContent();

      if (selected.length == 0) {
        chunk = 'code text here';
      } else {
        chunk = selected.text;
      }
      if (content.substr(selected.start-1,1) == '`'
          && content.substr(selected.end,1) == '`' ) {
        e.setSelection(selected.start-1,selected.end+1);
        e.replaceSelection(chunk);
        cursor = selected.start-1;
      } else {
        e.replaceSelection('`'+chunk+'`');
        cursor = selected.start+1;
      }
      e.setSelection(cursor,cursor+chunk.length);
    },
    _olistHandler: function(){
      var e = this, chunk, cursor, selected = e.getSelection(), content = e.getContent();

      if (selected.length == 0) {
        chunk = 'list text here';
        e.replaceSelection('1. '+chunk);
        cursor = selected.start+3;
      } else {
        if (selected.text.indexOf('\n') < 0) {
          chunk = selected.text;
          e.replaceSelection('1. '+chunk);
          cursor = selected.start+3;
        } else {
          var list = [];

          list = selected.text.split('\n');
          chunk = list[0];

          $.each(list,function(k,v) {
            list[k] = '1. '+v
          })
          e.replaceSelection('\n\n'+list.join('\n'));
          cursor = selected.start+5;
        }
      }
      e.setSelection(cursor,cursor+chunk.length);
    },
    _ulistHandler: function(){
      var e = this, chunk, cursor, selected = e.getSelection(), content = e.getContent()

      if (selected.length == 0) {
        chunk = 'list text here';
        e.replaceSelection('* '+chunk);
        cursor = selected.start+2;
      } else {
        if (selected.text.indexOf('\n') < 0) {
          chunk = selected.text;
          e.replaceSelection('* '+chunk);
          cursor = selected.start+2;
        } else {
          var list = [];

          list = selected.text.split('\n');
          chunk = list[0];

          $.each(list,function(k,v) {
            list[k] = '* '+v
          })
          e.replaceSelection('\n\n'+list.join('\n'));
          cursor = selected.start+4;
        }
      }
      e.setSelection(cursor,cursor+chunk.length);
    }
  };

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
