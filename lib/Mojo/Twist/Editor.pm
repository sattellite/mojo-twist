package Mojo::Twist::Editor;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(spurt encode);
use Mojo::Twist::Articles;
use Mojo::Twist::Renderer;
use File::Copy qw(move);
use POSIX qw(strftime);
use Data::Dumper;

sub articles {
  my $self  = shift;
  my $config = $self->config;
  my $years = $self->_find_all(
    path         => $config->{articles_root},
    article_args => {default_author => $config->{author}}
  );

  $self->render('editor-article', title => 'Admin interface', years => $years);
}

sub create {
  shift->render('editor-create');
}

sub drafts {
  my $self  = shift;
  my $config = $self->config;
  my $years = $self->_find_all(
    path         => $config->{drafts_root},
    article_args => {default_author => $config->{author}}
  );

  $self->render('editor-draft', title => 'Admin interface', years => $years);
}

sub hide {
  my $self = shift;
  my $config = $self->config;
  my $year   = $self->param('year');
  my $month  = $self->param('month');
  my $slug   = $self->param('slug');

  my $article = Mojo::Twist::Articles->new(
    path         => $config->{articles_root},
    article_args => {default_author => $config->{author}}
  )->find(slug => $slug);

  (my $file_name = $article->{file}->{path}) =~ s/^.*(\/.*\.md$)/$1/;
  move $config->{articles_root}.$file_name, $config->{drafts_root}.$file_name;
  unlink $config->{articles_root}.'/.cache';
  unlink $config->{drafts_root}.'/.cache';
  $self->render(json => {status => 'OK'})
}

sub prerender {
  my $self = shift;
  $self->render(json => {html => Mojo::Twist::Renderer->render( 'md', $self->param('content') ) });
}

sub preview {
  my $self = shift;
  my $config = $self->config;
  my $year   = $self->param('year');
  my $month  = $self->param('month');
  my $slug   = $self->param('slug');

  my $path = $config->{articles_root};
  my $draft = 0;
  if ( $self->stash('draft') ) {
    $path = $config->{drafts_root};
    $draft = 1;
    unlink $path.'/.cache';
  }

  my $article = Mojo::Twist::Articles->new(
    path         => $path,
    article_args => {default_author => $config->{author}}
  )->find(slug => $slug);

  my( $content, $date, $tags, $title, $uri );
  $title   = $article->title;
  $tags    = $article->tags;
  $uri     = $article->slug;
  $date    = $article->created->epoch;
  if ($article->_data->{preview} ne '' and $article->_data->{preview} ne $article->_data->{content}) {
    $content = $article->_data->{preview};
    $content .= "\n[cut]\n";
    $content .= $article->_data->{content};
  }
  else {
    $content = $article->_data->{content};
  }

  $self->respond_to(
    json => sub {
              $self->render(json => { article => { tags => $tags, title => $title, slug => $uri, content => $content, date => $date }});
            },
    html => sub {
              $self->render('editor-preview', title => $article->title, article => $article, draft => $draft);
            }
  );
}

sub publish {
  my $self = shift;
  my $config = $self->config;
  my $year   = $self->param('year');
  my $month  = $self->param('month');
  my $slug   = $self->param('slug');

  my $article = Mojo::Twist::Articles->new(
    path         => $config->{drafts_root},
    article_args => {default_author => $config->{author}}
  )->find(slug => $slug);

  (my $file_name = $article->{file}->{path}) =~ s/^.*(\/.*\.md$)/$1/;
  move $config->{drafts_root}.$file_name, $config->{articles_root}.$file_name;
  unlink $config->{articles_root}.'/.cache';
  unlink $config->{drafts_root}.'/.cache';
  $self->render(json => {status => 'OK'})
}

sub remove {
  my $self = shift;
  my $config = $self->config;
  my $year   = $self->param('year');
  my $month  = $self->param('month');
  my $slug   = $self->param('slug');

  my $article = Mojo::Twist::Articles->new(
    path         => $config->{drafts_root},
    article_args => {default_author => $config->{author}}
  )->find(slug => $slug);

  (my $file_name = $article->{file}->{path}) =~ s/^.*(\/.*\.md$)/$1/;
  unlink $config->{drafts_root}.$file_name;
  unlink $config->{drafts_root}.'/.cache';
  $self->render(json => {status => 'OK'})
}

sub save {
  my $self = shift;
  my $config = $self->config;
  my $date   = $self->param('date');
  my $title  = $self->param('title');
  my $oslug  = $self->param('oldslug');
  my $slug   = $self->param('slug');
  my $tags   = $self->param('tags');
  my $data   = $self->param('content');

  $oslug = $slug if ($oslug eq 'new-article-url');

  my $article = Mojo::Twist::Articles->new(
    path         => $config->{drafts_root},
    article_args => {default_author => $config->{author}}
  )->find(slug => $oslug);


  $date ||= strftime "%Y-%m-%d", localtime;
  my $file;
  if ($article) {
     $file = $article->{file}->{path};

    if ($oslug ne $slug) {
      unlink $file;
      $oslug = $slug;
      $file = $config->{drafts_root} . "/$date-$slug.md";
    }
  }
  else {
    $file = $config->{drafts_root} . "/$date-$slug.md";
  }

  $self->_write($file, $data, $title, $tags, $slug);

  unlink $config->{drafts_root}.'/.cache';

  $self->render(json => {status => 'OK'});
}

sub view {
  shift->redirect_to('/edit/articles');
}

sub _find_all {
  my $self = shift;
  my (%params) = @_;

  my $years    = {};
  my $articles = Mojo::Twist::Articles->new(
    path         => $params{path},
    article_args => $params{article_args}
  )->find_all;
  foreach my $article (@$articles) {
    $years->{$article->created->year} ||= {};
    $years->{$article->created->year}->{$article->created->month} ||= [];
    push @{$years->{$article->created->year}->{$article->created->month}},
      $article;
  }

  foreach my $year (keys %$years) {
    $years->{$year} = [
      map {
        { month    => $_,
          articles => $years->{$year}->{$_}
        }
      }
      sort { $b <=> $a } keys %{$years->{$year}}
    ];
  }

  return [
    map { {year => $_, months => $years->{$_}} }
    sort { $b <=> $a } keys %$years
  ];
}

sub _write {
  my ($class, $file, $data, $title, $tags, $slug) = @_;
  $data  ||= '';
  $title ||= '';
  $tags  ||= '';
  $slug  ||= '';

  my @data = ("Title: $title", "Tags: $tags", $slug ? "Slug: $slug" : '', "\n$data\n");
  @data = map { encode 'UTF-8', $_ } @data;
  spurt join("\n", @data), $file;

  return;
}

1;
