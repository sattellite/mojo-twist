use Test::More;

use strict;
use warnings;

use_ok 'Mojo::Twist::Renderer';

my $r = Mojo::Twist::Renderer->new;
ok($r->render('pod', '=head1 Foo') eq "\n<h1>Foo</h1>\n", 'Correct renderer pod');
ok($r->render('md', "Foo\n===") eq "<h1>Foo</h1>\n", 'Correct renderer markdown');
eval { $r->render('foo', '123') };
ok($@, 'Incorrect renderer');

done_testing();
