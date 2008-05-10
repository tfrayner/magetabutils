#!/usr/bin/env perl
#
# $Id$
#
# t/001_load.t - check module loading

use strict;
use warnings;

use Test::More tests => 38;

BEGIN {
    use_ok( 'Bio::MAGETAB' );
    use_ok( 'Bio::MAGETAB::BaseClass' );
    use_ok( 'Bio::MAGETAB::ArrayDesign' );
    use_ok( 'Bio::MAGETAB::Assay' );
    use_ok( 'Bio::MAGETAB::Comment' );
    use_ok( 'Bio::MAGETAB::CompositeElement' );
    use_ok( 'Bio::MAGETAB::Contact' );
    use_ok( 'Bio::MAGETAB::ControlledTerm' );
    use_ok( 'Bio::MAGETAB::Data' );
    use_ok( 'Bio::MAGETAB::DataAcquisition' );
    use_ok( 'Bio::MAGETAB::DatabaseEntry' );
    use_ok( 'Bio::MAGETAB::DataFile' );
    use_ok( 'Bio::MAGETAB::DataMatrix' );
    use_ok( 'Bio::MAGETAB::DesignElement' );
    use_ok( 'Bio::MAGETAB::Edge' );
    use_ok( 'Bio::MAGETAB::Event' );
    use_ok( 'Bio::MAGETAB::Extract' );
    use_ok( 'Bio::MAGETAB::Factor' );
    use_ok( 'Bio::MAGETAB::FactorValue' );
    use_ok( 'Bio::MAGETAB::Feature' );
    use_ok( 'Bio::MAGETAB::Investigation' );
    use_ok( 'Bio::MAGETAB::LabeledExtract' );
    use_ok( 'Bio::MAGETAB::Material' );
    use_ok( 'Bio::MAGETAB::MatrixColumn' );
    use_ok( 'Bio::MAGETAB::MatrixRow' );
    use_ok( 'Bio::MAGETAB::Measurement' );
    use_ok( 'Bio::MAGETAB::Node' );
    use_ok( 'Bio::MAGETAB::Normalization' );
    use_ok( 'Bio::MAGETAB::ParameterValue' );
    use_ok( 'Bio::MAGETAB::Protocol' );
    use_ok( 'Bio::MAGETAB::ProtocolApplication' );
    use_ok( 'Bio::MAGETAB::ProtocolParameter' );
    use_ok( 'Bio::MAGETAB::Publication' );
    use_ok( 'Bio::MAGETAB::Reporter' );
    use_ok( 'Bio::MAGETAB::Sample' );
    use_ok( 'Bio::MAGETAB::SDRF' );
    use_ok( 'Bio::MAGETAB::Source' );
    use_ok( 'Bio::MAGETAB::TermSource' );
}

