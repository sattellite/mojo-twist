# Mojo::Twist

[![Build Status](https://travis-ci.org/sattellite/mojo-twist.svg?branch=master)](https://travis-ci.org/sattellite/mojo-twist)

Blog engine writen on Perl with using Mojolicious.
This blog engine rewriten from [Twist](https://github.com/vti/twist).

![Screenshot](http://sattellite.me/screenshot.png)

## Features

    * filesystem-based storage
    * tags
    * RSS (articles, tags)
    * static pages
    * drafts
    * archive
    * Unicode support
    * POD and Markdown

## Installation

    $ git clone http://github.com/sattellite/mojo-twist.git
    $ cd mojo-twist
    $ morbo script/mojo_twist
    Server available at http://*:3000.

## Configuration

Copy `mojo-twist.json.sample` to `mojo-twist.json` and change it to fit your needs.

## Writing articles

Articles by default go into `articles/` directory.

Article consists of file information and content with meta data.

### File info

    20140317-article.pod
    or
    20140317T14:02:00-article.md

Where timestamp tells us when the article was created. Modified time is retrieved automatically from `mtime`. Filename is the article's permalink url.
Extention is article's format.

### Content

    Title: My first article
    Tags: blog, internet

    Welcome!

    [cut] Read more

    This is my first article. It is in C<pod> format. And I can use all kind of
    B<tags>.

Every article should have metadata. Metadata ends with an empty line. If there is a `[cut]` tag, article will be splitted into `preview` and `content`
parts. `preview` is shown when a) article list is requested, b) rss.

## Drafts

Drafts are available under `articles/drafts` url. Only you know the title, so it is
safe to put there your drafts and refresh browser to see how it looks.

## Static pages

Just put a `pod` or `md` into `pages/` directory. Pages are available under `/pages` url.
