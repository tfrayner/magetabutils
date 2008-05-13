#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    use_ok( 'Bio::MAGETAB::Investigation' );
}

INIT {
    use lib 't/testlib';
    use CommonTests qw(test_class);
}

my %required_attr = (
    title               => 'test',
);

use Bio::MAGETAB::Publication;
use Bio::MAGETAB::Protocol;
use Bio::MAGETAB::Contact;
use Bio::MAGETAB::ControlledTerm;
use Bio::MAGETAB::Factor;
use Bio::MAGETAB::TermSource;
use Bio::MAGETAB::Comment;
use Bio::MAGETAB::SDRF;
use Bio::MAGETAB::Normalization;

my $publ = Bio::MAGETAB::Publication->new();
my $prot = Bio::MAGETAB::Protocol->new( name => 'test protocol' );
my $cont = Bio::MAGETAB::Contact->new( lastName => 'test contact' );
my $cote = Bio::MAGETAB::ControlledTerm->new( category => 'test', value => 'test' );
my $fact = Bio::MAGETAB::Factor->new( name => 'test factor' );
my $teso = Bio::MAGETAB::TermSource->new( name => 'test termsource' );
my $comm = Bio::MAGETAB::Comment->new( name => 'test comment', value => 'value' );
my $norm = Bio::MAGETAB::Normalization->new( name => 'test norm' );
my $sdrf = Bio::MAGETAB::SDRF->new( nodes => [ $norm ], uri => 'http://test.com' );

my %optional_attr = (
    publications        => [ $publ ],
    protocols           => [ $prot ],
    contacts            => [ $cont ],
    date                => '2008-01-01',
    publicReleaseDate   => '2009-01-01',
    description         => 'test description',
    designTypes         => [ $cote ],
    replicateTypes      => [ $cote ],
    qualityControlTypes => [ $cote ],
    normalizationTypes  => [ $cote ],
    factors             => [ $fact ],
    termSources         => [ $teso ],
    comments            => [ $comm ],
    sdrfs               => [ $sdrf ],
);

my %bad_attr = (
    title               => [],
    publications        => 'test',
    protocols           => 'test',
    contacts            => 'test',
    date                => [],
    publicReleaseDate   => [],
    description         => [],
    designTypes         => 'test',
    replicateTypes      => 'test',
    qualityControlTypes => 'test',
    normalizationTypes  => 'test',
    factors             => 'test',
    termSources         => 'test',
    comments            => 'test',
    sdrfs               => 'test',
);

my $publ2 = Bio::MAGETAB::Publication->new( pubMedID => '12345678' );
my $prot2 = Bio::MAGETAB::Protocol->new( name => 'test protocol 2' );
my $cont2 = Bio::MAGETAB::Contact->new( lastName => 'test contact 2' );
my $cote2 = Bio::MAGETAB::ControlledTerm->new( category => 'test', value => 'test 2' );
my $fact2 = Bio::MAGETAB::Factor->new( name => 'test factor 2' );
my $teso2 = Bio::MAGETAB::TermSource->new( name => 'test termsource 2' );
my $comm2 = Bio::MAGETAB::Comment->new( name => 'test comment', value => 'value 2' );
my $norm2 = Bio::MAGETAB::Normalization->new( name => 'test norm 2' );
my $sdrf2 = Bio::MAGETAB::SDRF->new( nodes => [ $norm2 ], uri => 'file:///~/test.txt' );

my %secondary_attr = (
    title               => 'test2',
    publications        => [ $publ2 ],
    protocols           => [ $prot2 ],
    contacts            => [ $cont2 ],
    date                => '2008-01-02',
    publicReleaseDate   => '2009-01-02',
    description         => 'test description 2',
    designTypes         => [ $cote2 ],
    replicateTypes      => [ $cote2 ],
    qualityControlTypes => [ $cote2 ],
    normalizationTypes  => [ $cote2 ],
    factors             => [ $fact2 ],
    termSources         => [ $teso2 ],
    comments            => [ $comm2 ],
    sdrfs               => [ $sdrf2 ],
);

my $obj = test_class(
    'Bio::MAGETAB::Investigation',
    \%required_attr,
    \%optional_attr,
    \%bad_attr,
    \%secondary_attr,
);

ok( $obj->isa('Bio::MAGETAB::BaseClass'), 'object has correct superclass' );
