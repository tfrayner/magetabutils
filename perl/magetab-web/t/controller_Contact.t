use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Bio::MAGETAB::Util::Web' }
BEGIN { use_ok 'Bio::MAGETAB::Util::Web::Controller::Contact' }

ok( request('/contact')->is_success, 'Request should succeed' );


