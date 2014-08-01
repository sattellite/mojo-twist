package Mojo::Twist;
use Mojo::Base 'Mojolicious';

our $VERSION = '0.1.3';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Plugins

  # Config
  my $config = $self->plugin('JSONConfig');
  $config->{articles_root} = $self->home->rel_dir('articles');
  $config->{drafts_root}   = $self->home->rel_dir('articles/drafts');
  $config->{pages_root}    = $self->home->rel_dir('pages');

  $self->secrets($config->{secrets} || die '"secrets" is required in config file');

  # Hook
  $self->hook(before_render => sub {
    $config->{generator} ||= "Mojo::Twist $VERSION";
    $config->{footer} ||= q{Powered by <a href="http://github.com/sattellite/mojo-twist" target="_blank">Mojo::Twist</a>};
  });

  # Router
  my $r = $self->routes;

  $r->get('/')->to('router#all');
  $r->get('/rss.rss')->to('router#index_rss');
  $r->get('/articles/:year/:month/:slug')->to('router#concrete');
  $r->get('/drafts/:slug')->to('router#drafts');
  $r->get('/pages/:slug')->to('router#pages');
  $r->get('/archive')->to('router#archives');
  $r->get('/tags')->to('router#tags_all');
  $r->get('/tags/(:tag).rss')->to('router#tags_tag_rss');
  $r->get('/tags/:tag')->to('router#tags_tag');
}

1;
