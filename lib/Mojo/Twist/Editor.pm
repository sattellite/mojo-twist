package Mojo::Twist::Editor;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Twist::Articles;

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
