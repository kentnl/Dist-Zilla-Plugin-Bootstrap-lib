
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.4007"
  },
  "configure_requires" => {
    "Module::Build" => "0.4007"
  },
  "dist_abstract" => "A minimal boot-strapping for Dist::Zilla Plug-ins.",
  "dist_author" => [
    "Kent Fredric <kentnl\@cpan.org>"
  ],
  "dist_name" => "Dist-Zilla-Plugin-Bootstrap-lib",
  "dist_version" => "0.04000000",
  "license" => "perl",
  "module_name" => "Dist::Zilla::Plugin::Bootstrap::lib",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Dist::Zilla::Role::Bootstrap" => 0,
    "Moose" => 0,
    "perl" => "5.006",
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => [],
  "test_requires" => {
    "Cwd" => 0,
    "Dist::Zilla" => 0,
    "File::Copy::Recursive" => 0,
    "IO::Handle" => 0,
    "IPC::Open3" => 0,
    "Path::FindDev" => 0,
    "Path::Tiny" => 0,
    "Test::More" => "0.98"
  }
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  my $tr = delete $module_build_args{test_requires};
  my $br = $module_build_args{build_requires};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
