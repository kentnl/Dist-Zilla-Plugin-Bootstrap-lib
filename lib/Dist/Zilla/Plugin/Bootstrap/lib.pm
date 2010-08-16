use strict;
use warnings;

package Dist::Zilla::Plugin::Bootstrap::lib;

# ABSTRACT: A minimal bootstrapper for Dist::Zilla

=head1 SYNOPSIS

    [Bootstrap::lib]

=cut

=head1 DESCRIPTION

This module does the very simple task of
injecting the dists 'lib' directory into @INC
at the point of its inclusion, so that you can use
plugins you're writing for dist zilla, to release
the plugin itself.

=cut

=head1 USE CASES

This module really is only useful in the case where you need to use something like

    dzil -Ilib

For I<every> call to L<Dist::Zilla>, and this is mainly a convenience.
=cut

=head1 PRECAUTIONS

=head2 DO NOT

B<DO NOT> use this library from inside a bundle. It will not likely work as expected, and you B<DO NOT> want tobootstrap everything in all cases.

=head2 NO VERSION

At present, using this module in conjunction with a module with no explicitly defined version in the source wil result in the I<executed> instance of that plugin I<also> having B<NO VERSION>.

This may have a workaround in the future, but no guarantees.

=head2 NOT REALLY A PLUGIN

This is really just an inglorious hack masquerading as a plugin. In order to be useful for I<all> plugins that you may want to normally use with L<Dist::Zilla>, we subvert the entire plugin system and do all our work during C<require>.

=head2 GOOD LUCK

I wrote this plugin, mostly because I was boilerplating the code into every dist I had that needed it, and it became annoying, especially having to update the code accross distributions to handle L<Dist::Zilla> API changes.

=cut

use File::Spec;
my $lib;
BEGIN { $lib = File::Spec->catdir( File::Spec->curdir(), 'lib' ); }
use Carp;
use lib "$lib";
Carp::carp("[Bootstrap::lib] $lib added to \@INC");

sub log_debug          { 1; }
sub plugin_name        { 'Bootstrap::lib' }
sub dump_config        { }
sub register_component { }

1;
