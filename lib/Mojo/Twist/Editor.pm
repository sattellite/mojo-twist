package Mojo::Twist::Editor;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Twist::Articles;
use File::Copy qw(move);
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
  }

  my $article = Mojo::Twist::Articles->new(
    path         => $path,
    article_args => {default_author => $config->{author}}
  )->find(slug => $slug);

  $self->render('editor-preview', title => $article->title, article => $article, draft => $draft);
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

sub view {
  shift->redirect_to('/edit/articles');
}

1;


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

1;
