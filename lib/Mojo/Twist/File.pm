package Mojo::Twist::File;
use Mojo::Base -base;

use Mojo::Twist::Date;

use Encode ();
use File::stat;
use File::Basename ();

use constant FILE_SLURP => eval { require File::Slurp; 1 };

my $DATE_RE      = qr/(\d\d\d\d)-?(\d?\d)-?(\d?\d)/;
my $TIME_SEP_RE  = qr/_|:/;
my $TIME_RE      = qr/T?_?(\d\d)$TIME_SEP_RE?(\d\d)$TIME_SEP_RE?(\d\d)?/;
my $TIMESTAMP_RE = qr/$DATE_RE$TIME_RE?/;

sub path {
  my $self = shift;

  return $self->{path};
}

sub created {
  my $self = shift;

  return $self->{created} if $self->{created};

  my ($prefix) = File::Basename::basename($self->path) =~ m/^($TIMESTAMP_RE?)-/;

  if ($prefix && Mojo::Twist::Date->is_date($prefix)) {
    $self->{created} = Mojo::Twist::Date->new(timestamp => $prefix);
  }
  else {
    $self->{created} = $self->modified;
  }

  return $self->{created};
}

sub modified {
  my $self = shift;

  return Mojo::Twist::Date->new(epoch => $self->_stat->mtime);
}

sub filename {
  my $self = shift;

  return $self->{filename} if $self->{filename};

  my $filename = File::Basename::basename($self->path);

  my ($prefix) = $filename =~ m/^($TIMESTAMP_RE?)-/;
  if ($prefix && Mojo::Twist::Date->is_date($prefix)) {
    $filename =~ s/^$prefix-//;
  }

  $filename =~ s/\.[^\.]+$//;

  return $self->{filename} = $filename;
}

sub format {
  my $self = shift;

  return $self->{format} if $self->{format};

  my $filename = File::Basename::basename($self->path);

  my $format = '';
  if ($filename =~ m/\.([^\.]+)$/) {
    $format = $1;
  }

  return $self->{format} = $format;
}

sub slurp {
  my $self = shift;

  my $slurp =
    FILE_SLURP
    ? File::Slurp::read_file($self->path)
    : do { local $/; open my $fh, '<', $self->path or die $!; <$fh> };

  return Encode::decode('UTF-8', $slurp);
}

sub _stat {
  my $self = shift;

  return stat $self->path;
}

1;
