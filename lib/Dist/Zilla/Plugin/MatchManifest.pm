#---------------------------------------------------------------------
package Dist::Zilla::Plugin::MatchManifest;
#
# Copyright 2009 Christopher J. Madsen
#
# Author: Christopher J. Madsen <perl@cjmweb.net>
# Created: 17 Oct 2009
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either the
# GNU General Public License or the Artistic License for more details.
#
# ABSTRACT: Ensure that MANIFEST is correct
#---------------------------------------------------------------------

our $VERSION = '0.01';


use Moose;
use Moose::Autobox;
with 'Dist::Zilla::Role::InstallTool';

use autodie ':io';

sub setup_installer {
  my ($self, $arg) = @_;

  my $files = $self->zilla->files;

  # Find the existing MANIFEST:
  my $manifestFile = $files->grep(sub{ $_->name eq 'MANIFEST' })->head;

  # No MANIFEST; create one:
  unless ($manifestFile) {
    $manifestFile = Dist::Zilla::File::InMemory->new({
      name    => 'MANIFEST',
      content => '',
    });

    $self->add_file($manifestFile);
  } # end unless distribution already contained MANIFEST

  # List the files actually in the distribution:
  my $manifest = $files->map(sub{$_->name})->sort->join("\n") . "\n";

  return if $manifest eq $manifestFile->content;

  # We've got a mismatch.  Report it:
  require Text::Diff;

  my $onDisk = $self->zilla->root->file('MANIFEST');
  my $stat   = $onDisk->stat;

  my $diff = Text::Diff::diff(\$manifestFile->content, \$manifest, {
    qw(FILENAME_A MANIFEST  FILENAME_B MANIFEST  CONTEXT 0),
    MTIME_A => $stat ? $stat->mtime : 0,
    MTIME_B => time,
  });

  $diff =~ s/^\@\@.*\n//mg;     # Don't care about line numbers

  $self->zilla->log($diff);

  # See if the author wants to accept the new MANIFEST:
  die "Can't prompt about MANIFEST mismatch\n" unless -t STDIN and -t STDOUT;

  die "Aborted because of MANIFEST mismatch\n"
      unless $self->ask_yn("Update MANIFEST");

  # Update the MANIFEST in the distribution:
  $manifestFile->content($manifest);

  # And the original on disk:
  open(my $out, '>', $onDisk);
  print $out $manifest;
  close $out;
} # end setup_installer

#---------------------------------------------------------------------
sub ask_yn
{
  my ($self, $prompt) = @_;

  local $| = 1;
  print "$prompt? (y/n) ";

  my $response = <STDIN>;
  chomp $response;

  return lc $response eq 'y';
} # end ask_yn

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=head1 NAME

Dist::Zilla::Plugin::MatchManifest - Ensure that MANIFEST is correct

=head1 VERSION

This document describes version 0.01 of
Dist::Zilla::Plugin::MatchManifest, released October 20, 2009.

=head1 DESCRIPTION

If included, this plugin will ensure that the distribution contains a
F<MANIFEST> file and that its contents match the files collected by
Dist::Zilla.  If not, it will display the differences and (if STDIN &
STDOUT are TTYs) offer to update the F<MANIFEST>.

As I see it, there are 2 problems that a MANIFEST can protect against:

=over

=item 1.

A file I don't want to distribute winds up in the tarball

=item 2.

A file I did want to distribute gets left out of the tarball

=back

By keeping your MANIFEST under source control and using this plugin to
make sure it's kept up to date, you can protect yourself against both
problems.

=for Pod::Coverage
ask_yn
setup_installer

=head1 CONFIGURATION AND ENVIRONMENT

Dist::Zilla::Plugin::MatchManifest requires no configuration files or environment variables.

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

=head1 AUTHOR

Christopher J. Madsen  S<< C<< <perl AT cjmweb.net> >> >>

Please report any bugs or feature requests to
S<< C<< <bug-Dist-Zilla-Plugin-MatchManifest AT rt.cpan.org> >> >>,
or through the web interface at
L<http://rt.cpan.org/Public/Bug/Report.html?Queue=Dist-Zilla-Plugin-MatchManifest>

You can follow or contribute to Dist-Zilla-Plugin-MatchManifest's development at
L<< http://github.com/madsen/dist-zilla-plugin-matchmanifest >>.

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Christopher J. Madsen.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENSE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut
