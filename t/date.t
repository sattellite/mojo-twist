use Test::More;

use strict;
use warnings;
use POSIX qw(locale_h);
setlocale(LC_ALL, "C");

use_ok 'Mojo::Twist::Date';

my $d = Mojo::Twist::Date->new(epoch => 1234567890);
ok($d->epoch == 1234567890, 'Correct init with `epoch` parameter');

$d = Mojo::Twist::Date->new(timestamp => '2014-01-01');
ok($d->epoch == 1388534400, 'Correct init with `timestamp` parameter');

ok($d->year == 2014);
ok($d->month == 1);
ok($d->timestamp eq '20140101T00:00:00');
ok($d->strftime('%Y%m%d%H') eq '2014010100');
ok($d->is_date('2014-02-01'));
ok($d->is_date('20140201T13:14'));
ok(!$d->is_date('2014-02-01T13:14:15:16'));
ok($d->to_string eq 'Wed, 01 Jan 2014');
ok($d->to_rss eq 'Wed, 01 Jan 2014 00:00:00 GMT');

done_testing();
