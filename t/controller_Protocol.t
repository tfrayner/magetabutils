use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Bio::GeneSigDB::Web' }
BEGIN { use_ok 'Bio::GeneSigDB::Web::Controller::Protocol' }

ok( request('/protocol')->is_success, 'Request should succeed' );


