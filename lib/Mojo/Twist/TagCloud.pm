package Mojo::Twist::TagCloud;
use Mojo::Base -base;

use Mojo::Twist::Articles;

sub new {
  my $self = shift->SUPER::new;
  my (%params)  = @_;
  $self->{path} = $params{path};
  return $self;
}

sub cloud {
  my $self = shift;

  my $cloud    = {};
  my $articles = Mojo::Twist::Articles->new(path => $self->{path})->find_all;

  foreach my $article (@$articles) {
    my $tags = $article->tags;
    foreach my $tag (@$tags) {
      $cloud->{$tag}++;
    }
  }

  return [
    sort { $a->{name} cmp $b->{name} }
    map { {name => $_, count => $cloud->{$_}} } keys %$cloud
  ];
}

1;
