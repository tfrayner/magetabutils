#!/usr/bin/env perl
#
# $Id: Makefile.PL 1859 2007-12-17 13:20:58Z tfrayner $

use strict;
use warnings;

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Bio::MAGETAB',
    VERSION_FROM => 'lib/Bio/MAGETAB.pm', # finds \$VERSION
    AUTHOR       => 'Tim F. Rayner (tfrayner@gmail.com)',
    ABSTRACT     => 'Parser and data model for the MAGE-TAB format.',
    PREREQ_PM => {
        'Moose'           => "0.43",
        'Moose::Policy'   => "0.03",
        'Module::List'    => "0.001",
#        'Text::CSV_XS'    => "0.28",
    },
    EXE_FILES    => [
    ],
);
