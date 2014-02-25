use Test::More;

use strict;
use warnings;

use_ok 'Mojo::Twist::Articles';

my $dir = Mojo::Twist::Articles->new(path => 't/articles', article_args => {default_author => 'tester'});
my $a = $dir->find(slug => 'hello-there');
ok($dir->find(slug => 'hello-there')->content eq "\n<p>Hello world!</p>\n", 'Find article');
ok(@{$dir->find_all} == 4, 'Find all articles');
ok(@{$dir->find_all(limit => 2)} == 2, 'Find all articles with limit');
ok($a->{default_author} eq 'tester', 'Check article_args');
$a = $dir->find_all(offset => '20110924T12:12:12', limit => 1);
ok(@{$a} == 1, 'Find all articles with correct offset');
ok($a->[0]->slug eq 'very-good', 'Find all articles with correct offset');

unlink 't/articles/.cache';

done_testing();
