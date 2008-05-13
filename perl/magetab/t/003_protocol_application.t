#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::ProtocolApplication' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

use Bio::MAGETAB::Protocol;
use Bio::MAGETAB::ProtocolParameter;
use Bio::MAGETAB::Measurement;
use Bio::MAGETAB::ParameterValue;
use Bio::MAGETAB::Comment;

my $prot = Bio::MAGETAB::Protocol->new( name => 'test protocol' );
my $parm = Bio::MAGETAB::ProtocolParameter->new( name => 'test param', protocol => $prot );
my $meas = Bio::MAGETAB::Measurement->new( type => 'test measurement', value => 'value' );
my $pval = Bio::MAGETAB::ParameterValue->new( parameter => $parm, measurement => $meas );
my $comm = Bio::MAGETAB::Comment->new( name => 'test comment', value => 'of interest' );

my %required_attr = (
    protocol        => $prot,
);

my %optional_attr = (
    date            => '2008-01-01',
    parameterValues => [ $pval ],
    performers      => [ 'test performer' ],
    comments        => [ $comm ],
);

my %bad_attr = (
    protocol        => 'test',
    date            => [],
    parameterValues => 'test',
    performers      => 'test',
    comments        => [ 'test' ],
);

my $prot2 = Bio::MAGETAB::Protocol->new( name => 'test protocol 2' );
my $parm2 = Bio::MAGETAB::ProtocolParameter->new( name => 'test param', protocol => $prot2 );
my $meas2 = Bio::MAGETAB::Measurement->new( type => 'test measurement', value => 'value 2' );
my $pval2 = Bio::MAGETAB::ParameterValue->new( parameter => $parm2, measurement => $meas2 );
my $comm2 = Bio::MAGETAB::Comment->new( name => 'test comment', value => 'of interest 2' );

my %secondary_attr = (
    protocol        => $prot2,
    date            => '2008-01-01',
    parameterValues => [ $pval2 ],
    performers      => [ 'test performer2', 'test performer3' ],
    comments        => [ $comm2 ],
);

my $obj = test_class(
    'Bio::MAGETAB::ProtocolApplication',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::BaseClass'), 'object has correct superclass' );