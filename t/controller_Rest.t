use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Bio::GeneSigDB::Web' }
BEGIN { use_ok 'Bio::GeneSigDB::Web::Controller::Rest' }

ok( request('/rest')->is_success, 'Request should succeed' );


