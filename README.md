# Mojo::Twist

[![Build Status](https://travis-ci.org/sattellite/mojo-twist.svg?branch=master)](https://travis-ci.org/sattellite/mojo-twist)

Blog engine writen on Perl and Mojolicious.
This blog engine rewriten from [Twist](https://github.com/vti/twist).

![Default browser](http://sattellite.me/screenshot1.png)

## Features

* filesystem-based storage
* tags
* RSS (articles, tags)
* static pages
* drafts
* archive
* POD and Markdown
* [Google Analytics](https://www.google.com/analytics/web/) and [Yandex.Metrika](https://metrika.yandex.ru/)
* [Disqus](https://disqus.com) comments

## Installation

    $ git clone http://github.com/sattellite/mojo-twist.git
    $ cd mojo-twist
    $ cp mojo-twist.json.example mojo-twist.json
    $ cpan App::cpanminus && cpanm --installdeps .
    $ morbo script/mojo_twist
    Server available at http://*:3000.

## Configuration

Copy `mojo-twist.json.example` to `mojo-twist.json` and change it to fit your needs.
For configuration *nginx* web-server visit [wiki](https://github.com/sattellite/mojo-twist/wiki).

## Writing articles

Articles by default go into `articles/` directory.

Article consists of file information and content with meta data.

### File info

    20140317-article.pod
    or
    20140317T14:02:00-article.md

Where timestamp tells us when the article was created. Modified time is retrieved automatically from `mtime`. Filename is the article's permalink url. Extention is article's format.

### Content

    Title: My first article
    Tags: blog, internet

    Welcome!

    [cut] Read more

    This is my first article. It is in `md` format. And I can use all kind of
    **tags**.

Every article should have metadata. Metadata ends with an empty line. If there is a `[cut]` tag, article will be splitted into `preview` and `content` parts. `preview` is shown when:
- article list is requested,
- rss.

#### Images

For images used [jQuery.LazyLoad](https://github.com/tuupola/jquery_lazyload/). Preprocessor replace each `<img src="..."` with `<img data-original="..."`.

#### Responsive design

Design of blog is responsive and have good view in desktop and mobile browsers.

![Mobile browser](http://sattellite.me/screenshot2.png)

#### Google Analytics and Yandex.Metrika

In configuration file you can specify your unique keys for Google Analytics or/and Yandex.Metrika.
All needed scripts will be included in templates if theirs keys was setted.

#### Disqus

If you have `disqus` account then you can include disqus comments for each article by specifying your  `disqus shortname`.

## Drafts

Drafts are available under `/drafts` url. Drafts in the `articles/drafts` directory. Only you know the title, so it is safe to put there your drafts and refresh browser to see how it looks.
For example: file `articles/drafts/2014-08-31-Sample-draft.md` will be available under `drafts/Sample-draft` url.

## Static pages

Just put a `pod` or `md` into `pages/` directory. Pages are available under `/pages` url.
