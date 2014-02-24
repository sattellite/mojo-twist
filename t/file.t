use Test::More;

use strict;
use warnings;
use POSIX qw(locale_h);
setlocale(LC_ALL, "C");

use_ok 'Mojo::Twist::File';

my $file = 't/file/foo.md';
my $f = Mojo::Twist::File->new(path => $file);
ok($f->path eq $file);
my $atime = 1388534400;
my $mtime = 1388534400+3600*24;
utime($atime, $mtime, $file);
# ok($f->created eq 'Wed, 01 Jan 2014');
ok($f->created eq 'Thu, 02 Jan 2014');
ok($f->modified eq 'Thu, 02 Jan 2014');
ok($f->filename eq 'foo');
ok($f->format eq 'md');
ok($f->slurp eq "foobarbaz\n");

done_testing();
