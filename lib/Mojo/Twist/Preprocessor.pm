package Mojo::Twist::Preprocessor;
use Mojo::Base -base;

sub new {
  my $self = shift->SUPER::new;
  my (%params) = @_;

  $self->{cuttag}               = $params{cuttag} || '[cut]';
  $self->{default_preview_link} = $params{default_preview_link} || 'Keep reading';

  return $self;
}

sub parse {
  my $self = shift;
  my ($content) = @_;

  my $cuttag = quotemeta $self->{cuttag};

  my ($preview, $preview_link);

  if ($content =~ s{^(.*?)\r?\n$cuttag(?: (.*?))?\r?\n}{}s) {
    $preview = $1;
    $preview_link = $2 || $self->{default_preview_link};
  }

  return {
    preview      => $preview ? $preview : $content,
    preview_link => $preview_link ? $preview_link : $self->{default_preview_link},
    content      => $content
  };
}

1;
