#!/usr/bin/env perl
#
# Copyright 2008 Tim Rayner
# 
# This file is part of Bio::MAGETAB::Util.
# 
# Bio::MAGETAB::Util is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# Bio::MAGETAB::Util is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Bio::MAGETAB::Util.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id$
#
# t/001_load.t - check module loading

use strict;
use warnings;

use Test::More tests => 14;

BEGIN {
    use_ok( 'Bio::MAGETAB::Util::Builder' );
    use_ok( 'Bio::MAGETAB::Util::Reader::Tabfile' );
    use_ok( 'Bio::MAGETAB::Util::Reader::TagValueFile' );
    use_ok( 'Bio::MAGETAB::Util::Reader::ADF' );
    use_ok( 'Bio::MAGETAB::Util::Reader::DataMatrix' );
    use_ok( 'Bio::MAGETAB::Util::Reader::IDF' );
    use_ok( 'Bio::MAGETAB::Util::Reader::SDRF' );
    use_ok( 'Bio::MAGETAB::Util::Reader' );
    use_ok( 'Bio::MAGETAB::Util::Writer' );
    use_ok( 'Bio::MAGETAB::Util::Writer::BaseClass' );
    use_ok( 'Bio::MAGETAB::Util::Writer::IDF' );
    use_ok( 'Bio::MAGETAB::Util::Writer::ADF' );
    use_ok( 'Bio::MAGETAB::Util::Writer::SDRF' );
    use_ok( 'Bio::MAGETAB::Util::Writer::Graphviz' );
}

