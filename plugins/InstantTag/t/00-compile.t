use strict;
use lib qw( t/lib lib extlib );
use warnings;
use MT;
use Test::More tests => 2;
use MT::Test;

ok(MT->component('InstantTag'), "InstantTag plugin loaded correctry");

require_ok('InstantTag');

1;
