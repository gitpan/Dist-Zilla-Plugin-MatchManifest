
use strict;
use warnings;



use ExtUtils::MakeMaker 6.11;



my %WriteMakefileArgs = (
                       'test' => {
                                   'TESTS' => 't/*.t'
                                 },
                       'NAME' => 'Dist::Zilla::Plugin::MatchManifest',
                       'DISTNAME' => 'Dist-Zilla-Plugin-MatchManifest',
                       'CONFIGURE_REQUIRES' => {
                                                 'ExtUtils::MakeMaker' => '6.11'
                                               },
                       'AUTHOR' => 'Christopher J. Madsen <perl@cjmweb.net>',
                       'BUILD_REQUIRES' => {},
                       'ABSTRACT' => 'Ensure that MANIFEST is correct',
                       'EXE_FILES' => [],
                       'VERSION' => '0.02',
                       'PREREQ_PM' => {
                                        'Text::Diff' => '0',
                                        'autodie' => '0',
                                        'Dist::Zilla' => '1.100660',
                                        'Moose::Autobox' => '0.09',
                                        'Moose' => '0.65'
                                      },
                       'LICENSE' => 'perl'
                     );


delete $WriteMakefileArgs{LICENSE}
  unless eval { ExtUtils::MakeMaker->VERSION(6.31) };

WriteMakefile(%WriteMakefileArgs);



