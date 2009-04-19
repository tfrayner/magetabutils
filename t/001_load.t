#!/usr/bin/env perl
#
# Copyright 2009 Tim Rayner
# 
# This file is part of Bio::GeneSigDB.
# 
# Bio::GeneSigDB is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# Bio::GeneSigDB is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Bio::GeneSigDB.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id: 001_load.t 58 2008-07-09 09:09:33Z tfrayner $
#
# t/001_load.t - check module loading

use strict;
use warnings;

use Test::More tests => 24;

BEGIN {
    use_ok( 'Bio::GeneSigDB' );
    use_ok( 'Bio::GeneSigDB::Platform' );
    use_ok( 'Bio::GeneSigDB::Array' );
    use_ok( 'Bio::GeneSigDB::Database' );
    use_ok( 'Bio::GeneSigDB::Element' );
    use_ok( 'Bio::GeneSigDB::Signature' );
    use_ok( 'Bio::GeneSigDB::PublishedSignature' );
    use_ok( 'Bio::GeneSigDB::Category' );
    use_ok( 'Bio::GeneSigDB::Provenance' );
    use_ok( 'Bio::GeneSigDB::MAGETAB' );
    use_ok( 'Bio::GeneSigDB::Persistence' );
    use_ok( 'Bio::GeneSigDB::Web' );
    use_ok( 'Bio::GeneSigDB::Web::Model::DB' );
    use_ok( 'Bio::GeneSigDB::Web::View::HTML' );
    use_ok( 'Bio::GeneSigDB::Web::Controller::BaseClass' );
    use_ok( 'Bio::GeneSigDB::Web::Controller::Contact' );
    use_ok( 'Bio::GeneSigDB::Web::Controller::Factor' );
    use_ok( 'Bio::GeneSigDB::Web::Controller::Investigation' );
    use_ok( 'Bio::GeneSigDB::Web::Controller::Protocol' );
    use_ok( 'Bio::GeneSigDB::Web::Controller::Publication' );
    use_ok( 'Bio::GeneSigDB::Web::Controller::Rest' );
    use_ok( 'Bio::GeneSigDB::Web::Controller::Root' );
    use_ok( 'Bio::GeneSigDB::Web::Controller::SDRF' );
    use_ok( 'Bio::GeneSigDB::Web::Controller::TermSource' );
}

