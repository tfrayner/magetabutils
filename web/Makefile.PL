#!/usr/bin/env perl
#
# Copyright 2008 Tim Rayner
# 
# This file is part of Bio::MAGETAB::Util::Web.
# 
# Bio::MAGETAB::Util::Web is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# Bio::MAGETAB::Util::Web is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Bio::MAGETAB::Util::Web.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id$

use strict;
use warnings;

use inc::Module::Install;

name 'Bio-MAGETAB-Util-Web';
all_from 'lib/Bio/MAGETAB/Util/Web.pm';

requires 'Catalyst::Runtime'                  => '5.7015';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Action::REST';
requires 'Tangram';
requires 'Class::Tangram';
requires 'Bio::MAGETAB::Util::Reader'         => '0.4';
requires 'Bio::MAGETAB::Util::Persistence';
requires 'parent';
requires 'Config::YAML';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
