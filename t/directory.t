use Test::More;

use strict;
use warnings;
use POSIX qw(locale_h);
setlocale(LC_ALL, "C");
use Time::HiRes qw(usleep);
use File::stat;

use_ok 'Mojo::Twist::Directory';

unlink 't/directory/.cache';

my $d = Mojo::Twist::Directory->new(path => 't/file');
ok($d->files->[0]->{path} eq 't/file/foo.md', 'Read file path');
ok(-f 't/file/.cache', 'Check cache');

#Reread directory
unlink 't/file/.cache';
my $dir = Mojo::Twist::Directory->new(path => 't/file');
$dir->files;
undef $dir;
my $old_stat = stat 't/file/.cache';
usleep 10000;
open my $fh, '>', 't/file/new_file';
print $fh 'foo';
close $fh;
$dir = Mojo::Twist::Directory->new(path => 't/file');
$dir->files;
undef $dir;
my $new_stat = stat 't/file/.cache';
unlink 't/file/new_file';
ok($old_stat->size != $new_stat->size, 'Reread directory');
unlink 't/file/.cache';

done_testing();
