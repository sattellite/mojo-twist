package Mojo::Twist::Editor;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Twist::Archive;

sub view {
  my $self = shift;
  my $config = $self->config;
  my $years  = Mojo::Twist::Archive->new(
    path         => $config->{articles_root},
    article_args => {default_author => $config->{author}}
  )->archive;

  $self->render('editor-view', title => 'Admin interface', years => $years);
}

1;
