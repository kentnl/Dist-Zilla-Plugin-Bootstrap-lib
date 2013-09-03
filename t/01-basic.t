use strict;
use warnings;

use Test::More;
use Path::FindDev qw( find_dev );
use Path::Tiny;
use Cwd qw( cwd );
use File::Copy::Recursive qw( rcopy );

my $source = find_dev('./')->child('corpus')->child('fake_dist_01');
my $tempdir = Path::Tiny->tempdir;

rcopy( "$source", "$tempdir" );

BAIL_OUT("test setup failed to copy to tempdir") if not -e -f $tempdir->child("dist.ini");

my $cwd = cwd();
chdir "$tempdir";

is( system("dzil", "build"), 0, "dzil build ran ok");

chdir $cwd;

done_testing;








