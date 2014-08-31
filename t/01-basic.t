use strict;
use warnings;

use Test::More;
use Test::DZil qw( simple_ini );
use Dist::Zilla::Util::Test::KENTNL 1.003001 qw(dztest);
require Dist::Zilla::Plugin::Bootstrap::lib;

my $t = dztest();
$t->add_file(
  'dist.ini' => simple_ini(
    { name => 'E' },
    [ 'Bootstrap::lib', ],    #
    ['=E'],
  )
);
$t->add_file( 'lib/E.pm', <<'EOF');
use strict;
use warnings;
package E;

sub register_component {}

1;
EOF

$t->build_ok;

note explain $t->builder->log_messages;

done_testing;
