package Mojo::Twist::Renderer;
use Mojo::Base -base;

use Class::Load;

sub render {
    my $self = shift;
    my ($format, $string) = @_;

    my $renderer_class = 'Mojo::Twist::Renderer::' . ucfirst $format;
    Class::Load::load_class($renderer_class);

    (my $content = $renderer_class->new->render($string)) =~ s/img\s+src/img data-original/g;

    return $content;
}

1;
