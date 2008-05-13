#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);
use Test::Exception;

BEGIN {
    use_ok( 'Bio::MAGETAB::Edge' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

use Bio::MAGETAB::Source;
use Bio::MAGETAB::Sample;
use Bio::MAGETAB::Extract;
use Bio::MAGETAB::Protocol;
use Bio::MAGETAB::ProtocolApplication;

my $so = Bio::MAGETAB::Source->new(  name => 'test source'  );
my $sa = Bio::MAGETAB::Sample->new(  name => 'test sample'  );
my $ex = Bio::MAGETAB::Extract->new( name => 'test extract' );

my $pr = Bio::MAGETAB::Protocol->new( name => 'test protocol' );
my $pa = Bio::MAGETAB::ProtocolApplication->new(
    protocol => $pr,
    date     => '2008-01-01',
);

my %required_attr = (
    inputNode            => $so,
    outputNode           => $sa,
);

my %optional_attr = (
    protocolApplications => [ $pa ],
);

my %bad_attr = (
    inputNode            => [],
    outputNode           => 'test',
    protocolApplications => 'test',
);

my $pa2 = Bio::MAGETAB::ProtocolApplication->new(
    protocol => $pr,
    date     => '2008-01-02',
);

my %secondary_attr = (
    inputNode            => $sa,
    outputNode           => $ex,
    protocolApplications => [ $pa2 ],
);

my $obj = test_class(
    'Bio::MAGETAB::Edge',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::BaseClass'), 'object has correct superclass' );

my $ex2 = Bio::MAGETAB::Extract->new( name => 'test extract 2' );
my $ex3 = Bio::MAGETAB::Extract->new( name => 'test extract 3' );

# FIXME needs to test reciprocal relationship
is( $obj->get_outputNode(), $ex, 'initial state prior to reciprocity test' );
lives_ok( sub{ $obj->set_outputNode($ex2) }, 'setting outputNode via self' );
is_deeply( $ex2->get_inputEdges(), $obj, 'sets inputEdges in target node' );
lives_ok( sub{ $ex3->set_inputEdges( [ $obj ] ) }, 'setting inputEdges via target node' );

TODO : {
    local $TODO = 'Reciprocal associations only set via Edge for now; needs to be implemented for Node also.';
    is( $obj->get_outputNode(), $ex3, 'sets outputNode in self' );
}
