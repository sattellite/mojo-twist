package Mojo::Twist::Renderer::Md;
use Mojo::Base -base;

use Text::Markdown;

sub render {
  my $self = shift;
  my ($md) = @_;

  my $parser = Text::Markdown->new;
  my $output = $parser->markdown($md);

  return $output;
}

1;
