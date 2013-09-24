use strict;
use warnings;

use Test::More;
use Path::FindDev qw( find_dev );
use Path::Tiny;
use Cwd qw( cwd );
use File::Copy::Recursive qw( rcopy );
use Test::DZil;
use Test::Fatal;

my $dist = 'fake_dist_02';

my $source  = find_dev('./')->child('corpus')->child($dist);
my $tempdir = Path::Tiny->tempdir;

rcopy( "$source", "$tempdir" );

BAIL_OUT("test setup failed to copy to tempdir") if not -e -f $tempdir->child("dist.ini");

is(
  exception {
    my $builder = Builder->from_config(
      {
        dist_root => "$tempdir"
      }
    );
    $builder->build;
  },
  undef,
  'can build dist ' . $dist
);

done_testing;

