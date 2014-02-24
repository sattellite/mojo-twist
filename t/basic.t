use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Mojo::Twist');
$t->get_ok('/')->status_is(200)->text_is('head title' => 'Hacking')->content_type_like(qr/text\/html/);
$t->get_ok('/notfound')->status_is(404)->text_is('head title' => 'Error 404')->content_type_like(qr/text\/html/);
$t->get_ok('/pages/about')->status_is(200)->text_is('head title' => 'About')->content_type_like(qr/text\/html/);
$t->get_ok('/archive')->status_is(200)->text_is('div.text h1' => 'Archive')->content_type_like(qr/text\/html/);
$t->get_ok('/tags')->status_is(200)->text_is('div.text h1' => 'Tags')->content_type_like(qr/text\/html/);
$t->get_ok('/rss.rss')->status_is(200);
$t->get_ok('/tag/notfound')->status_is(404)->content_type_like(qr/text\/html/);
$t->get_ok('/tag/notfound.rss')->status_is(404);

done_testing();
