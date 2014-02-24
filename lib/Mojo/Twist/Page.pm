package Mojo::Twist::Page;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Twist::Articles;

# Render main page
sub all {
  my $self = shift;
  my $page = $self->param('page') || 1;
  # my $articles =
  $self->render(text => "Hello! Page #$page with all articles.");
}

# Render concrete article
sub concrete {
  my $self = shift;
  my $year = $self->param('year');
  my $month = $self->param('month');
  my $slug = $self->param('slug');
  $self->render(text => "Concrete article `$slug` created $year-$month");
}

1;
