
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  DISTNAME  => 'Dist-Zilla-Plugin-MatchManifest',
  NAME      => 'Dist::Zilla::Plugin::MatchManifest',
  AUTHOR    => "Christopher\ J\.\ Madsen\ \<perl\@cjmweb\.net\>",
  ABSTRACT  => "Ensure\ that\ MANIFEST\ is\ correct",
  VERSION   => '0.01',
  EXE_FILES => [ qw() ],
  (eval { ExtUtils::MakeMaker->VERSION(6.31) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM    => {
    "Text::Diff" => '0',
    "Dist::Zilla" => '1.092680',
    "autodie" => '0',
    "Moose::Autobox" => '0.09',
    "Moose" => '0.65',
  },
  test => {TESTS => 't/*.t'}
);

