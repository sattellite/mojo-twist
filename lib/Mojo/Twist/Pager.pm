package Mojo::Twist::Pager;
use Mojo::Base -base;

use Mojo::Twist::Articles;

sub new {
  my $self = shift->SUPER::new;
  my (%params) = @_;

  $self->{path}   = $params{path};
  $self->{offset} = $params{offset};
  $self->{limit}  = $params{limit};

  $self->{articles} = Mojo::Twist::Articles->new(path => $self->{path})->find_all;

  if ($self->{offset}) {
    my $i;
    for ($i = 0; $i < @{$self->{articles}}; $i++) {
      next
        unless $self->{articles}->[$i]->created->timestamp
          le $self->{offset};
      last;
    }

    $self->{current} = $i;
  }
  else {
      $self->{current} = 0;
  }
  return $self;
}

sub next {
  my $self = shift;

  my $next = $self->{current} + $self->{limit};

  return if $next >= @{$self->{articles}};

  return $self->{articles}->[$next]->created->timestamp;
}

sub prev {
  my $self = shift;

  my $prev = $self->{current} - $self->{limit};

  return if $prev < 0;

  return $self->{articles}->[$prev]->created->timestamp;
}

1;
