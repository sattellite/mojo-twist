use Test::More;

use strict;
use warnings;

use_ok 'Mojo::Twist::Preprocessor';

my $p = Mojo::Twist::Preprocessor->new;

my $t = $p->parse("Hello there\n[cut] Foobar\nAnd here");
ok( ($t->{preview_link} eq 'Foobar'
    and $t->{content} eq 'And here'
    and $t->{preview} eq 'Hello there'), 'Parse article');

$t = $p->parse("Hello there\r\n[cut] Foobar\r\nAnd here");
ok( ($t->{preview_link} eq 'Foobar'
    and $t->{content} eq 'And here'
    and $t->{preview} eq 'Hello there'), 'Parse article with \r');

$t = $p->parse("Hello there\n[cut]\nAnd here");
ok( ($t->{preview_link} eq 'Keep reading'
    and $t->{content} eq 'And here'
    and $t->{preview} eq 'Hello there'), 'Article without preview_link');

$t = $p->parse("Hello there");
ok( ($t->{preview_link} eq ''
    and $t->{content} eq 'Hello there'
    and $t->{preview} eq ''), 'Article without preview');

done_testing();
