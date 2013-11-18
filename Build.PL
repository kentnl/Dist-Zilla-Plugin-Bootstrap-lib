
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.4200"
  },
  "configure_requires" => {
    "Module::Build" => "0.4200"
  },
  "dist_abstract" => "A minimal boot-strapping for Dist::Zilla Plug-ins.",
  "dist_author" => [
    "Kent Fredric <kentnl\@cpan.org>"
  ],
  "dist_name" => "Dist-Zilla-Plugin-Bootstrap-lib",
  "dist_version" => "0.04000002",
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
    "File::Copy::Recursive" => 0,
    "Path::FindDev" => 0,
    "Path::Tiny" => 0,
    "Test::DZil" => 0,
    "Test::Fatal" => 0,
    "Test::More" => "1.001002"
  }
);


my %fallback_build_requires = (
  "Cwd" => 0,
  "File::Copy::Recursive" => 0,
  "Module::Build" => "0.4200",
  "Path::FindDev" => 0,
  "Path::Tiny" => 0,
  "Test::DZil" => 0,
  "Test::Fatal" => 0,
  "Test::More" => "1.001002"
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  delete $module_build_args{test_requires};
  $module_build_args{build_requires} = \%fallback_build_requires;
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
