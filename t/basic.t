use Test::More;
use Test::Mojo;
use Mojo::Home;

BEGIN {
  our $home = Mojo::Home->new->detect;
  $ENV{MOJO_CONFIG} = $home->rel_file('basic.json');
};

my $t = Test::Mojo->new('Mojo::Twist');
$t->ua->max_redirects(2);

$t->app->config->{articles_root} = $home->rel_dir('basic');
$t->app->config->{drafts_root}   = $home->rel_dir('basic/draft');

$t->get_ok('/')->status_is(200)->text_is('html head title' => $t->app->config->{title})->content_like(qr/Yet another Perl hacker/)->content_type_like(qr/text\/html/);
$t->get_ok('/notfound')->status_is(404)->text_is('html head title' => 'Error 404')->content_like(qr/Sorry, the page you're looking for is not found :\(/)->content_type_like(qr/text\/html/);
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

subtest 'Anonymous User' => sub {
  $t->get_ok('/login')
    ->status_is(200)
    ->text_is( 'html head title' => 'Login' )
    ->content_like( qr/Login/ )
    ->element_exists( 'form.form-login' );
};

subtest 'Do Login' => sub {

  # fail username
  $t->post_ok( '/login' => form => {user => 'wronguser', pass => $t->app->config->{auth}->{pass}} )
    ->status_is(200)
    ->content_like( qr/Username or password is incorrect/ )
    ->element_exists( 'form.form-login' );

  # fail password
  $t->post_ok( '/login' => form => {user => $t->app->config->{auth}->{user}, pass => 'wrongpass' } )
    ->status_is(200)
    ->content_like( qr/Username or password is incorrect/ )
    ->element_exists( 'form.form-login' );

  # successfully login
  my $tt = Test::Mojo->new('Mojo::Twist');
  $tt->ua->max_redirects(2);
  $tt->app->config->{articles_root} = $home->rel_dir('basic');
  $tt->app->config->{drafts_root}   = $home->rel_dir('basic/draft');
  $tt->ua->on(start => sub {
  my ($ua, $tx) = @_;
    $tx->req->headers->referrer('http://127.0.0.1:'.$ua->server->{nb_port}.'/articles/2014/2/First-article');
  });
  $tt->post_ok( '/login' => form => {username => $t->app->config->{auth}->{user}, password => $t->app->config->{auth}->{pass}} )
    ->status_is(200)
    ->text_is('html head title' => 'First article')
    ->element_exists_not( 'form.form-login' );
};

unlink ($t->app->config->{articles_root} . '/.cache');
unlink ($t->app->config->{drafts_root} . '/.cache');
unlink ($t->app->config->{pages_root} . '/.cache');

done_testing();
