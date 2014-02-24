package Mojo::Twist::Archive;
use Mojo::Base -base;

use Mojo::Twist::Articles;

sub new {
  my $self = shift->SUPER::new;
  my (%params) = @_;

  $self->{months_names} ||= {
    1  => 'January',
    2  => 'February',
    3  => 'March',
    4  => 'April',
    5  => 'May',
    6  => 'June',
    7  => 'July',
    8  => 'August',
    9  => 'September',
    10 => 'October',
    11 => 'November',
    12 => 'December',
  };
  $self->{path} = $params{path};
  $self->{article_args} = $params{article_args};

  return $self;
}

sub archive {
  my $self = shift;

  my $years    = {};
  my $articles = Mojo::Twist::Articles->new(
    path         => $self->{path},
    article_args => $self->{article_args}
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
        { month    => $self->{months_names}->{$_},
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
