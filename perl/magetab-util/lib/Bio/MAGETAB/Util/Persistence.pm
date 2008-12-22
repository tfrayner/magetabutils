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

package Bio::MAGETAB::Util::Persistence;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Carp;
use Tangram;

# This is where the magic happens. This needs to be kept synchronised
# with any changes made to the core MAGETAB model.
my $hashref = {

    classes => [

        ArrayDesign => {
            bases  => [ qw( DatabaseEntry ) ],
            fields => {
                string => [ qw( name
                                version
                                provider
                                printingProtocol
                                uri ) ],

                ref    => [ qw( technologyType
                                surfaceType
                                substrateType
                                sequencePolymerType )],

                array  => { designElements => 'DesignElement',
                            comments       => 'Comment', },
            },
        },

        ControlledTerm => {
            bases  => [ qw( DatabaseEntry ) ],
            fields => {
                string => [ qw( category
                                value ) ],
            },
        },

        DatabaseEntry => {
            fields => {
                string => [ qw( accession ) ],
                ref    => [ qw( termSource ) ],
            },
        },

        TermSource    => {
            fields => {
                string => [ qw( name
                                uri
                                version ) ],
            },
        },

        DesignElement => {
            abstract => 1,
            fields => {
                string => [ qw( chromosome
                                startPosition
                                endPosition ) ],
            },
        },

        Feature => {
            bases => [ qw( DesignElement ) ],
            fields => {

                # N.B. column is a reserved word, we use col as an
                # abbreviation (and blockCol for consistency).
                int => [ qw( blockCol
                             blockRow
                             col
                             row ) ],
            },
        },
        
        Comment => {
            fields => {
                string => [ qw( name
                                value ) ],
            },
        },
    ],
};

has 'config' => ( is       => 'ro',
                  isa      => 'HashRef',
                  required => 1,
                  default  => sub { $hashref }, );

sub deploy {

    my ( $self, $dbh ) = @_;

    my $schema = Tangram::Relational->schema( $self->get_config() );

    Tangram::Relational->deploy( $schema, $dbh );

    return;
}

no Moose;

1;
