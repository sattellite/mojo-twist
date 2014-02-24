use Test::More;

use strict;
use warnings;

use_ok 'Mojo::Twist::Pager';

my $p = Mojo::Twist::Pager->new(path => 't/pager', limit => 2);

ok($p->next eq '20110923T12:12:12', 'should find next page without offset');

$p = Mojo::Twist::Pager->new(path => 't/pager', limit => 2, offset => '20110923T12:12:12');
ok($p->next eq '20110921T12:12:12', 'should find next page with offset');

$p = Mojo::Twist::Pager->new(path => 't/pager', limit => 2, offset => '20110922T12:12:12');
ok(! $p->next, 'should not find next when no pages available');

$p = Mojo::Twist::Pager->new(path => 't/pager', limit => 2);
ok(! $p->prev, 'should not find prev page without offset');

$p = Mojo::Twist::Pager->new(path => 't/pager', limit => 2, offset => '20110924T12:12:12');
ok(! $p->prev, 'should not find prev page when offset is not enough');

done_testing();
