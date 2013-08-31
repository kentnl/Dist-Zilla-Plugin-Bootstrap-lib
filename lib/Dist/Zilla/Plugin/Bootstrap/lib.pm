use strict;
use warnings;
## no critic ( NamingConventions::Capitalization )
package Dist::Zilla::Plugin::Bootstrap::lib;
BEGIN {
  $Dist::Zilla::Plugin::Bootstrap::lib::AUTHORITY = 'cpan:KENTNL';
}
{
  $Dist::Zilla::Plugin::Bootstrap::lib::VERSION = '0.03000100';
}
## use critic;

# ABSTRACT: A minimal boot-strapping for Dist::Zilla Plug-ins.




use Cwd qw( cwd );


sub log_debug { return 1; }


sub plugin_name { return 'Bootstrap::lib' }


## no critic (RequireArgUnpacking)
sub new {
  return bless $_[1], $_[0];
}


sub does {
  require Role::Tiny;
  ## no critic (ProhibitNoWarnings)
  { no warnings 'redefine'; *does = \&Role::Tiny::does_role }
  goto &Role::Tiny::does_role;
}


## no critic (RequireArgUnpacking)
sub meta {
  require Moo::HandleMoose::FakeMetaClass;
  my $class = ref( $_[0] ) || $_[0];
  return bless { name => $class }, 'Moo::HandleMoose::FakeMetaClass';
}


sub dump_config { return { q{} . __PACKAGE__, $_[0]->{config} } }

sub _bootstrap_dir {
  my ($dir) = @_;
  require lib;
  lib->import($dir);
  return $dir;
}

sub _bootstrap_source_lib {
  my ($config) = @_;

  my $cwd    = $config->{cwd};
  my $logger = $config->{logger};

  my $libdir = $cwd->child('lib')->stringify;
  $logger->log( [ 'bootstrapping %s', $libdir ] );
  return _boostrap_dir($libdir);
}

sub _try_bootstrap_built {
  my ($config) = @_;

  my $logger   = $config->{logger};
  my $distname = $config->{distname};
  my $cwd      = $config->{cwd};
  my $fallback = $config->{fallback};

  my $libdir = $cwd->child($distname)->stringify;

  $logger->log_debug( [ 'trying to bootstrap %s-*', $libdir ] );

  my (@candidates) = grep { $_->basename =~ /^\Q$distname\E-/ } grep { $_->is_dir } $cwd->children;

  if ( scalar @candidates != 1 and not $fallback ) {
    $logger->log( [ 'candidates for bootstrap (%s) != 1, and fallback disabled. not bootstrapping', 0 + @candidates ] );
    $logger->log_debug( [ 'candidate: %s', $_->basename ] ) for @candidates;
    return;
  }
  if ( scalar @candidates != 1 and $fallback ) {
    $logger->log( [ 'candidates for bootstrap (%s) != 1, and fallback to boostrapping lib/', 0 + @candidates ] );
    $logger->log_debug( [ 'candidate: %s', $_->basename ] ) for @candidates;
    return _bootstrap_dir( $cwd->child('lib')->stringify );
  }

  my $found = $candidates[0]->child('lib');
  $logger->log( [ 'bootstrapping %s', $found->stringify ] );
  return _bootstrap_dir( $found->stringify );
}


sub register_component {
  my ( $plugin_class, $name, $payload, $section ) = @_;
  my $zilla  = $section->sequence->assembler->zilla;
  my $logger = $zilla->chrome->logger->proxy(
    {
      proxy_prefix => '[' . $name . '] ',
    }
  );
  my $distname = $zilla->name;
  $logger->log_debug( [ 'online, %s v%s', $plugin_class, $plugin_class->VERSION || 0 ] );

  $payload->{try_built} = undef if not exists $payload->{try_built};

  if ( $payload->{try_built} ) {
    $payload->{fallback} = 1     if not exists $payload->{fallback};
    $payload->{fallback} = undef if exists $payload->{no_fallback};
  }

  require Path::Tiny;
  my $cwd = Path::Tiny::path(cwd);

  my $bootstrap_path;

  if ( not $payload->{try_built} ) {
    $bootstrap_path = _bootstrap_source_lib( { cwd => $cwd, logger => $logger } );
  }
  else {
    $bootstrap_path =
      _try_bootstrap_built( { cwd => $cwd, logger => $logger, fallback => $payload->{fallback}, distname => $distname } );
  }

  push @{ $zilla->plugins }, __PACKAGE__->new(
    {
      config => {
        ( exists $payload->{try_built}   ? ( try_built   => $payload->{try_built} )   : () ),
        ( exists $payload->{fallback}    ? ( fallback    => $payload->{fallback} )    : () ),
        ( exists $payload->{no_fallback} ? ( no_fallback => $payload->{no_fallback} ) : () ),

      }
    }
  );

  return unless defined $bootstrap_path;

  my $root = Path::Tiny::path($bootstrap_path);

  my $it = $root->iterator( { recurse => 1 } );

  while ( my $file = $it->() ) {
    next unless $file->basename =~ /[.]pm$/msx;
    my $rpath = $file->relative($root)->stringify;
    if ( exists $INC{$rpath} ) {
      $logger->log( [ '%s was not bootstrapped. You need to move Bootstrap::lib higher', $rpath ] );
    }
  }

  return 1;

}

1;

__END__

=pod

=head1 NAME

Dist::Zilla::Plugin::Bootstrap::lib - A minimal boot-strapping for Dist::Zilla Plug-ins.

=head1 VERSION

version 0.03000100

=head1 SYNOPSIS

    [Bootstrap::lib]
    try_built   = 1  ; try using an existing built distribution named Dist-Name-*
    no_fallback = 1  ; if try_built can't find a built distribution, or there's more than one, don't bootstrap
                     ; using lib/ instead

=head1 DESCRIPTION

This module does the very simple task of
injecting the distributions 'lib' directory into @INC
at the point of its inclusion, so that you can use
plug-ins you're writing for L<< C<Dist::Zilla>|Dist::Zilla >>, to release
the plug-in itself.

=head1 METHODS

=head2 C<log_debug>
    1;

=head2 C<plugin_name>
    'Bootstrap::lib'

=head2 C<new>

    my $conf = __PACKAGE__->new({ config => \%arbitrary_hash});

=head2 C<does>

Lazily invokes Role::Tiny::does_role on demand.

=head2 C<meta>

Lazily creates a meta object using Moo

=head2 C<dump_config>

Dumps the configuration of this plugin to C<dzil>

=head2 C<register_component>

This is where all the real work happens.

=head1 USE CASES

=head2 Simple single-phase self-dependency

This module really is only useful in the case where you need to use something like

    dzil -Ilib

For I<every> call to L<< C<Dist::Zilla>|Dist::Zilla >>, and this is mainly a convenience.

For that

    [Bootstrap::lib]

on its own will do the right thing.

=head2 Installed-Only self-dependency

The other useful case is when you would normally do

    dzil build                 # pass 1 that generates Foo-1.234 with a pre-installed Foo-1.233
    dzil -IFoo-1.234/lib build # pass 2 that generates Foo-1.234 with Foo-1.234

For that

    [Bootstap::lib]
    try_built   = 1
    no_fallback = 1

Will do what you want.

    dzil build   # pass1 -> creates Foo-1.234 without bootstrapping
    dzil build   # pass2 -> creates Foo-1.234 boot-strapped from the previous build

=head2 2-step self-dependency

There's a 3rd useful case which is a hybrid of the 2, where you /can/ build from your own sources without needing a pre-installed version,
just you don't want that for release code ( e.g.: $VERSION being C<undef> in code that is run during release is "bad" )

    [Bootstrap::lib]
    try_built = 1
    fallback  = 1

Then

    dzil build  # pass1 -> creates Foo-1.234 from bootstrapped $root/lib
    dzil build  # pass2 -> creates Foo-1.234 from bootstrapped $root/Foo-1.234

=head1 PRECAUTIONS

=head2 DO NOT

B<DO NOT> use this library from inside a bundle. It will not likely work as expected, and you B<DO NOT> want
to bootstrap everything in all cases.

=head2 NO VERSION

On its own,

    [Bootstrap::lib]

At present, using this module in conjunction with a module with no explicitly defined version in the
source will result in the I<executed> instance of that plug-in I<also> having B<NO VERSION>.

If this is a problem for you, then its suggested you try either variation of using

    [Bootstrap::lib]
    try_built = 1
    ; no_fallback = 1   #

=head2 SUCKS AT GUESSING

The core mechanism behind C<try_built> relies on looking in your project directory for a previous build directory of some kind.

And there's no way for it to presently pick a "best" version when there are more than one, or magically provide a better solution
if there are "zero" versions readily available.

This is mostly because there is no way to determine the "current" version we are building for, because the point in the execution
cycle is so early, no version plugins are likely to be even instantiated yet, and some version plugins are dependent on incredibly
complex precursors ( like git ), so by even trying to garner the version we're currently building, we could be prematurely cutting off
a vast majority of modules from even being able to bootstrap.

Even as it is, us using C<< zilla->name >> means that if your dist relies on some process to divine its name, the module that does this must

=over 4

=item * be loaded and declared prior to C<Bootstrap::lib> in the C<dist.ini>

=item * not itself be the module you are presently developing/bootstrapping

=back

The only way of working around that I can envision is adding parameters to C<Bootstrap::lib> to specify the dist name and version name... but if you're going to do that, you may as well stop using external plugins to discover that, and hard-code those values in C<dist.ini> to start with.

=head2 STILL NOT REALLY A PLUGIN

Though the interface is getting more plugin-like every day, all of the behaviour is still implemented at construction time, practically as soon as the underlying Config::MVP engine has parsed it from the configuration.

As such, it is completely removed from the real plugin execution phases, and unlike real plugins which appear on the plugin stash, this module does not appear there.

=head2 GOOD LUCK

I wrote this plug-in, mostly because I was boiler-plating the code into every dist I had that needed it, and
it became annoying, especially having to update the code across distributions to handle
L<< C<Dist::Zilla>|Dist::Zilla >> C<API> changes.

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
