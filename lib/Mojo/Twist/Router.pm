package Mojo::Twist::Router;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::Twist::Articles;
use Mojo::Twist::Pager;
use Mojo::Twist::Archive;
use Mojo::Twist::TagCloud;

# Render main page
sub all {
  my $self = shift;
  my $config = $self->config;
  my $timestamp = $self->param('timestamp');

  my $articles = Mojo::Twist::Articles->new(
    path         => $config->{articles_root},
    article_args => {default_author => $config->{author}}
  )->find_all(
    offset => $timestamp,
    limit  => $config->{page_limit}
  );

  my $pager = Mojo::Twist::Pager->new(
    path   => $config->{articles_root},
    offset => $timestamp,
    limit  => $config->{page_limit}
  );

  $self->render('index', articles => $articles, pager => $pager);
}

sub archives {
  my $self = shift;
  my $config = $self->config;
  my $years  = Mojo::Twist::Archive->new(
    path         => $config->{articles_root},
    article_args => {default_author => $config->{author}}
  )->archive;

  $self->render('archive', title => 'Archive', years => $years);
}

# Render concrete article
sub article {
  my $self = shift;
  my $config = $self->config;
  my $year   = $self->param('year');
  my $month  = $self->param('month');
  my $slug   = $self->param('slug');

  my $article = Mojo::Twist::Articles->new(
    path         => $config->{articles_root},
    article_args => {default_author => $config->{author}}
  )->find(slug => $slug);

  if (!$article) {
    $self->render('not_found');
  }
  else {
    $self->render('article', title => $article->title, article => $article);
  }
}

sub drafts {
  my $self = shift;
  my $config = $self->config;
  my $slug   = $self->param('slug');

  my $article = Mojo::Twist::Articles->new(
    path         => $config->{drafts_root},
    article_args => {default_author => $config->{author}}
  )->find(slug => $slug);

  if (!$article) {
    $self->render('not_found');
  }
  else {
    $self->render('article', title => $article->title, article => $article);
  }
}

sub index_rss {
  my $self = shift;
  my $config    = $self->config;
  my $timestamp = $self->param('timestamp');

  my $articles = Mojo::Twist::Articles->new(
    path         => $config->{articles_root},
    article_args => {default_author => $config->{author}}
  )->find_all(limit => $config->{page_limit});

  $self->render('rss/articles', format => 'xml',
      pub_date => @$articles
      ? $articles->[0]->created->to_rss
      : Mojo::Twist::Date->new(epoch => time)->to_rss,
      articles => $articles);
}

sub pages {
  my $self = shift;
  my $config = $self->config;
  my $slug   = $self->param('slug');

  my $page = Mojo::Twist::Articles->new(
    path         => $config->{pages_root},
    article_args => {default_author => $config->{author}}
  )->find(slug => $slug);

  if (!$page) {
    $self->render('not_found');
  }
  else {
    $self->render('page', title => $page->title, page => $page);
  }
}


sub tags_all {
  my $self = shift;
  my $config    = $self->config;
  my $tag_cloud = Mojo::Twist::TagCloud->new(path => $config->{articles_root});

  $self->render('tags', title => 'Tags', tags  => $tag_cloud->cloud);
}

sub tags_tag {
  my $self = shift;
  my $config    = $self->config;
  my $timestamp = $self->param('timestamp');
  my $tag       = $self->param('tag');

  my $articles = Mojo::Twist::Articles->new(
    path         => $config->{articles_root},
    article_args => {default_author => $config->{author}}
  )->find_all(
    tag    => $tag,
    offset => $timestamp,
    limit  => $config->{page_limit}
  );

  $self->render('tag', title => $tag, articles => $articles, tag => $tag);
}

sub tags_tag_rss {
  my $self = shift;
  my $config    = $self->config;
  my $timestamp = $self->param('timestamp');
  my $tag       = $self->param('tag');

  my $articles = Mojo::Twist::Articles->new(path => $config->{articles_root})
  ->find_all(
    tag   => $tag,
    limit => $config->{page_limit}
  );

  $self->render('rss/tag', format => 'xml',
    articles => $articles, tag => $tag,
    pub_date => @$articles
      ? $articles->[0]->created->to_rss
      : Mojo::Twist::Date->new(epoch => time)->to_rss
    );
}

1;
