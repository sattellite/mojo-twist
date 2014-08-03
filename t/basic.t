use Test::More;
use Test::Mojo;
use Mojo::Home;

BEGIN {
  our $home = Mojo::Home->new->detect;
  $ENV{MOJO_CONFIG} = $home->rel_file('basic.json');
};

my $t = Test::Mojo->new('Mojo::Twist');

$t->app->config->{articles_root} = $home->rel_dir('basic');
$t->app->config->{drafts_root}   = $home->rel_dir('basic/draft');

$t->get_ok('/')->status_is(200)->text_is('head title' => 'Hacking')->content_type_like(qr/text\/html/);
$t->get_ok('/notfound')->status_is(404)->text_is('head title' => 'Error 404')->content_type_like(qr/text\/html/);
$t->get_ok('/articles/2014/2/First-article')->status_is(200)->text_is('head title' => 'First article')->content_type_like(qr/text\/html/);;
$t->get_ok('/drafts/First-article')->status_is(200)->text_is('head title' => 'First article')->content_type_like(qr/text\/html/);;
$t->get_ok('/pages/about')->status_is(200)->text_is('head title' => 'About')->content_type_like(qr/text\/html/);
$t->get_ok('/archive')->status_is(200)->text_is('article h1' => 'Archive')->content_type_like(qr/text\/html/);
$t->get_ok('/tags')->status_is(200)->text_is('article h1' => 'Tags')->content_type_like(qr/text\/html/);
$t->get_ok('/tags/article')->status_is(200)->text_is('article h1' => 'Tag article')->content_type_like(qr/text\/html/);
$t->get_ok('/tags/article.rss')->status_is(200)->content_type_is('application/xml');
$t->get_ok('/rss.rss')->status_is(200)->content_type_isnt('text/html');
$t->get_ok('/tag/notfound')->status_is(404)->content_type_like(qr/text\/html/);
$t->get_ok('/tag/notfound.rss')->status_is(404)->content_type_isnt('text/html');

unlink ($t->app->config->{articles_root} . '/.cache');
unlink ($t->app->config->{drafts_root} . '/.cache');
unlink ($t->app->config->{pages_root} . '/.cache');

done_testing();
