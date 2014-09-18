package Mojo::Twist;
use Mojo::Base 'Mojolicious';
our $VERSION = '0.2.2';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Config
  my $config = $self->plugin('JSONConfig');
  $config->{articles_root} = $self->home->rel_dir('articles');
  $config->{drafts_root}   = $self->home->rel_dir('articles/drafts');
  $config->{pages_root}    = $self->home->rel_dir('pages');

  $self->secrets($config->{secrets});
  $self->sessions->default_expiration(86400); # One day

  # Auth plugin configuration
  $self->plugin('Authentication' => {
    'autoload_user' => 1,
    'load_user' => sub {
      my ($c, $uid) = (shift, shift);
      return {} if ($uid eq 'editor');
      return undef;
    },
    'validate_user' => sub {
      my $c    = shift;
      my $user = shift || '';
      my $pass = shift || '';
      return 'editor' if ($user eq $config->{auth}->{user} &&
                          $pass eq $config->{auth}->{pass});
      return undef;
    },
  });


  # Hook
  $self->hook(before_render => sub {
    $config->{generator} ||= "Mojo::Twist $VERSION";
    $config->{footer} ||= q{Powered by <a href="http://github.com/sattellite/mojo-twist" target="_blank">Mojo::Twist</a>};
  });

  # Router
  my $r = $self->routes;

  $r->get('/')->to('router#all');
  $r->get('/rss.rss')->to('router#index_rss');
  $r->get('/sitemap.xml')->to('router#sitemap');
  $r->get('/articles/:year/:month/:slug')->to('router#article');
  $r->get('/drafts/:slug')->to('router#drafts');
  $r->get('/pages/:slug')->to('router#pages');
  $r->get('/archive')->to('router#archives');
  $r->get('/tags')->to('router#tags_all');
  $r->get('/tags/(:tag).rss')->to('router#tags_tag_rss');
  $r->get('/tags/:tag')->to('router#tags_tag');

  # Auth routes
  $r->post('/login')->to('user#login');
  $r->get('/login')->to('user#show');
  $r->get('/logout')->to('user#delete');
  # Only for authenticated users
  my $auth = $r->under('/')->to('user#auth');
  $auth->get('/edit')->to('editor#view');
  $auth->get('/edit/articles')->to('editor#articles');
  $auth->get('/edit/drafts')->to('editor#drafts');
  $auth->get('/edit/preview/:year/:month/:slug')->to('editor#preview');
  $auth->get('/edit/preview/draft/:year/:month/:slug')->to('editor#preview', draft => 1);
  $auth->post('/edit/prerender')->to('editor#prerender');
  $auth->post('/edit/hide/:year/:month/:slug')->to('editor#hide');
  $auth->post('/edit/publish/:year/:month/:slug')->to('editor#publish');
  $auth->post('/edit/remove/:year/:month/:slug')->to('editor#remove');
  $auth->post('/edit/save')->to('editor#save');
}

1;
