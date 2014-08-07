package Mojo::Twist::User;
use Mojo::Base 'Mojolicious::Controller';

sub auth {
  my $self = shift;
  $self->render('login') and return undef unless $self->is_user_authenticated;
  return 1;
}

sub delete {
  my $self = shift;
  $self->logout;
  $self->redirect_to('/');
}

sub login {
  my $self = shift;
  my $name = $self->param('name') || q{};
  my $pass = $self->param('pass') || q{};
  if ( $self->authenticate( $name, $pass ) ) {
    $self->redirect_to($self->req->headers->referrer);
  }
  else {
    $self->flash( message => 'Username or password is incorrect', username => $name );
    $self->redirect_to($self->req->headers->referrer);
  }
}

sub show {
  shift->render('login');
}

1;
