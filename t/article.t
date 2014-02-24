use Test::More;

use strict;
use warnings;
use POSIX qw(locale_h);
setlocale(LC_ALL, "C");

use_ok 'Mojo::Twist::Article';

use Mojo::Twist::File;

my $a = Mojo::Twist::Article->new(
  file => Mojo::Twist::File->new(
    path => 't/article/20110922T121212-hello-there.pod'
  )
);

ok($a->created eq 'Thu, 22 Sep 2011');
ok($a->created->year eq '2011');
ok($a->title eq 'Hello');
ok(scalar($a->tags)->[0] eq scalar([qw/foo bar baz/])->[0]);
ok(scalar($a->tags)->[1] eq scalar([qw/foo bar baz/])->[1]);
ok(scalar($a->tags)->[2] eq scalar([qw/foo bar baz/])->[2]);
ok($a->preview eq "\n<p>Hello world!</p>\n");
ok($a->preview_link eq 'Foobar');
ok($a->content eq "\n<h1>Hello!</h1>\n");

done_testing();
