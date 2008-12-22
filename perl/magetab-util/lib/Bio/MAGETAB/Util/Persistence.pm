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

                array  => { designElements => 'DesignElement', },
                iarray => { comments       => 'Comment', },
            },
        },

        Assay => {
            bases  => [ qw( Event ) ],
            fields => {
                ref => [ qw( arrayDesign
                             technologyType ) ],
            },
        },

        BaseClass => {
            abstract => 1,
            fields   => {
                string => [ qw( authority namespace ) ],
            },
        },

        CompositeElement => {
            bases  => [ qw( DesignElement ) ],
            fields => {
                string => [ qw( name ) ],
                array  => { databaseEntries => 'DatabaseEntry', },
                iarray => { comments        => 'Comment', },
            },
        },

        Comment => {
            bases  => [ qw( BaseClass ) ],
            fields => {
                string => [ qw( name
                                value ) ],
            },
        },

        Contact => {
            bases  => [ qw( BaseClass ) ],
            fields => {
                string => [ qw( firstName
                                lastName
                                midInitials
                                email
                                organization
                                phone
                                fax
                                address ) ],
                array  => { roles    => 'ControlledTerm' },
                iarray => { comments => 'Comment', },
            },
        },

        ControlledTerm => {
            bases  => [ qw( DatabaseEntry ) ],
            fields => {
                string => [ qw( category
                                value ) ],
            },
        },

        Data => {
            abstract => 1,
            bases    => [ qw( Node ) ],
            fields   => {
                string => [ qw( uri ) ],
                ref    => [ qw( type ) ],
            },
        },

        DataAcquisition => {
            bases => [ qw( Event ) ],
        },

        DatabaseEntry => {
            bases  => [ qw( BaseClass ) ],
            fields => {
                string => [ qw( accession ) ],
                ref    => [ qw( termSource ) ],
            },
        },

        DataFile => {
            bases  => [ qw( Data ) ],
            fields => {
                ref => [ qw( format ) ],
            },
        },
        
        DataMatrix => {
            bases  => [ qw( Data ) ],
            fields => {
                string => [ qw( rowIdentifierType ) ],
                iarray => { matrixRows    => 'MatrixRow',
                            matrixColumns => 'MatrixColumn', },
            },
        },

        DesignElement => {
            abstract => 1,
            bases    => [ qw( BaseClass ) ],
            fields   => {
                string => [ qw( chromosome
                                startPosition
                                endPosition ) ],
            },
        },

        Edge => {
            bases  => [ qw( BaseClass ) ],
            fields => {
                ref   => [ qw( inputNode
                               outputNode ) ],
                array => { protocolApplications => 'ProtocolApplication' },
            },
        },

        Event => {
            abstract => 1,
            bases    => [ qw( Node ) ],
            fields   => {
                string => [ qw( name ) ],
            },
        },

        Extract => {
            bases => [ qw( Material ) ],
        },

        Factor => {
            bases  => [ qw( BaseClass ) ],
            fields => {
                string => [ qw( name ) ],
                ref    => [ qw( type ) ],
            },
        },

        FactorValue => {
            bases  => [ qw( BaseClass ) ],
            fields => {
                ref => [ qw( measurement
                             term
                             factor ) ],
            },
        },

        Feature => {
            bases  => [ qw( DesignElement ) ],
            fields => {

                # N.B. column is a reserved word, we use col as an
                # abbreviation (and blockCol for consistency).
                int => [ qw( blockCol
                             blockRow
                             col
                             row ) ],
            },
        },

        Investigation => {
            bases  => [ qw( BaseClass ) ],
            fields => {
                string => [ qw( title
                                description
                                date
                                publicReleaseDate) ],
                array  => { contacts            => 'Contact',
                            protocols           => 'Protocol',
                            publications        => 'Publication',
                            termSources         => 'TermSource',
                            designTypes         => 'ControlledTerm',
                            normalizationTypes  => 'ControlledTerm',
                            replicateTypes      => 'ControlledTerm',
                            qualityControlTypes => 'ControlledTerm', },
                iarray => { factors      => 'Factor',
                            sdrfs        => 'SDRF',
                            comments     => 'Comment', },
            },
        },
        
        LabeledExtract => {
            bases   => [ qw( Material ) ],
            fields  => {
                ref => [ qw( label ) ],
            },
        },

        Material => {
            abstract => 1,
            bases    => [ qw( Node ) ],
            fields   => {
                string => [ qw( name description ) ],
                ref    => [ qw( type ) ],
                array  => { characteristics => 'ControlledTerm' },
                iarray => { measurements    => 'Measurement' },
            },
        },

        MatrixColumn => {
            bases  => [ qw( BaseClass ) ],
            fields => {
                int   => [ qw( columnNumber ) ],
                ref   => [ qw( quantitationType ) ],
                array => { referencedNodes => 'Node' },
            },
        },

        MatrixRow => {
            bases  => [ qw( BaseClass ) ],
            fields => {
                int => [ qw( rowNumber ) ],
                ref => [ qw( designElement ) ],
            },
        },

        Measurement => {
            bases  => [ qw( BaseClass ) ],
            fields => {
                string => [ qw( type
                                value
                                minValue
                                maxValue ) ],
                ref    => [ qw( unit ) ],
            },
        },

        Node => {
            abstract => 1,
            bases    => [ qw( BaseClass ) ],
            fields   => {
                array => { inputEdges  => 'Edge',
                           outputEdges => 'Edge',
                           comments    => 'Comment',
                           sdrfRows    => 'SDRFRow', },
            },
        },

        Normalization => {
            bases => [ qw( Event ) ],
        },

        ParameterValue => {
            bases  => [ qw( BaseClass ) ],
            fields => {
                ref    => [ qw( measurement parameter ) ],
                iarray => { comments => 'Comment' },
            },
        },

        Protocol => {
            bases  => [ qw( BaseClass ) ],
            fields => {
                string => [ qw( name
                                text
                                software
                                hardware
                                contact ) ],
                ref    => [ qw( type ) ],
            },
        },

        ProtocolApplication => {
            bases  => [ qw( BaseClass ) ],
            fields => {

                # Performers is a semicolon-delimited list.
                string => [ qw( date performers ) ],
                ref    => [ qw( protocol ) ],
                iarray => { parameterValues => 'ParameterValue',
                            comments        => 'Comment', },
            },
        },

        ProtocolParameter => {
            bases  => [ qw( BaseClass ) ],
            fields => {
                string => [ qw( name ) ],
                ref    => [ qw( protocol ) ],
            },
        },

        Publication => {
            bases  => [ qw( BaseClass ) ],
            fields => {
                string => [ qw( title authorList pubMedID DOI ) ],
                ref    => [ qw( status ) ],
            },
        },

        Reporter => {
            bases  => [ qw( DesignElement ) ],
            fields => {
                string => [ qw( name sequence ) ],
                ref    => [ qw( controlType ) ],
                array  => { compositeElements => 'CompositeElement',
                            databaseEntries   => 'DatabaseEntry',
                            groups            => 'ControlledTerm', },
            },
        },

        SDRF => {
            bases  => [ qw( BaseClass ) ],
            fields => {
                string => [ qw( uri ) ],
                iarray => { sdrfRows => 'SDRFRow' },
            },
        },

        SDRFRow => {
            bases  => [ qw( BaseClass ) ],
            fields => {
                int   => [ qw( rowNumber ) ],
                array => { nodes        => 'Node',
                           factorValues => 'FactorValue', },
                ref   => [ qw( channel ) ],
            },
        },

        Sample => {
            bases => [ qw( Material ) ],
        },

        Source => {
            bases  => [ qw( Material ) ],
            fields => {

                # Providers is a semicolon-delimited list.
                string => [ qw( providers ) ],
            },
        },

        TermSource => {
            bases  => [ qw( BaseClass ) ],
            fields => {
                string => [ qw( name
                                uri
                                version ) ],
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
