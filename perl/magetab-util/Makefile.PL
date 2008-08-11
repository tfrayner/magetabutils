#!/usr/bin/env perl
#
# Copyright 2008 Tim Rayner
# 
# This file is part of Bio::MAGETAB.
# 
# Bio::MAGETAB is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# Bio::MAGETAB is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Bio::MAGETAB.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id$

use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Bio::MAGETAB',
    VERSION_FROM => 'lib/Bio/MAGETAB.pm', # finds \$VERSION
    AUTHOR       => 'Tim F. Rayner (tfrayner@gmail.com)',
    LICENSE      => 'gpl',
    ABSTRACT     => 'Parser and data model for the MAGE-TAB format.',
    PREREQ_PM => {
        'Moose'                       => "0.43",
        'Moose::Policy'               => "0.03",
        'Test::Exception'             => "0.26",
        'MooseX::Types'               => "0.04",
        'Params::Coerce'              => "0.14",
        'URI'                         => "1.35",
        'Date::Manip'                 => "5.44",
        'DateTime'                    => "0.4302",
        'DateTime::Format::DateManip' => "0.04",
        'Email::Valid'                => "0.179",
    },
    EXE_FILES    => [
    ],
);
