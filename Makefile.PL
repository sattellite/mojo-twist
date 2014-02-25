use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Mojo::Twist',
    AUTHOR       => q{sattellite <sattellite@ya.ru>},
    VERSION_FROM => 'lib/Mojo/Twist.pm',
    ABSTRACT     => 'Mojo::Twist',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
        ? ('LICENSE' => 'MIT')
        : ()),
    PL_FILES  => {},
    PREREQ_PM => {
        'Class::Load'    => 0,
        'Mojolicious'    => 4.63,
        'Time::Piece'    => 0,
        'Test::Spec'     => 0,
        'Text::Markdown' => 0,
    },
    dist  => {COMPRESS => 'gzip -9f', SUFFIX => 'gz',},
    clean => {FILES    => 'Mojo-Twist-*'},
);
