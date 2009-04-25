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

use strict;
use warnings;

use inc::Module::Install;

name     'Bio-MAGETAB-Util';
abstract 'Import, export and visualization functions for the MAGE-TAB format.';
all_from 'lib/Bio/MAGETAB/Util/Reader.pm';

requires 'Bio::MAGETAB'                => '0.96';
requires 'Moose'                       => '0.43';
requires 'Moose::Policy'               => '0.03';
requires 'Parse::RecDescent'           => '1.96.0';
requires 'Text::CSV_XS'                => '0.32';

test_requires 'Test::Exception'        => '0.26';

recommends 'GraphViz'                  => '2.03';
recommends 'Tangram'                   => '2.10';
recommends 'DBI'                       => '';
recommends 'DBD::SQLite'               => '';

install_script glob('script/*.pl');
auto_install;
WriteAll;
