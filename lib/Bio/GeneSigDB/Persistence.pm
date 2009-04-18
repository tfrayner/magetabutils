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
# $Id$

package Bio::GeneSigDB::Persistence;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::GeneSigDB::Persistence' };

sub class_config {

    my ( $class ) = @_;

    my $hashref = $class::SUPER->class_config();

    my @genesig_classes = (

        'Bio::GeneSigDB::Provenance' => {
            fields => {
                string => [ qw( notes
                                reference ) ],
            },
        },

        'Bio::GeneSigDB::Platform' => {
            fields => {
                string => [ qw( name
                                biomartFilter ) ],
            },
        },

        'Bio::GeneSigDB::Array' => {
            bases => [ 'Bio::GeneSigDB::Platform' ],
            fields => {
                string => [ qw( manufacturer ) ],
            },
        },

        'Bio::GeneSigDB::Database' => {
            bases => [ 'Bio::GeneSigDB::Platform' ],
            fields => {
                string => [ qw( uri ) ],
            },
        },

        'Bio::GeneSigDB::Category' => {
            fields => {
                string => [ qw( name ) ],
                ref    => [ qw( parentCategory ) ],
            },
        },

        'Bio::GeneSigDB::Element' => {
            fields => {
                string => [ qw( identifier ) ],
                ref    => [ qw( platform ) ],
            },
        },

        'Bio::GeneSigDB::PublishedSignature' => {
            bases  => [ 'Bio::GeneSigDB::Signature' ],
            fields => {
                string => [ qw( criteria ) ],
                ref    => [ qw( provenance ) ],
            },
        },

        'Bio::GeneSigDB::Signature' => {
            fields => {
                string => [ qw( name species notes ) ],
                array  => { categories => 'Bio::GeneSigDB::Category',
                            elements   => 'Bio::GeneSigDB::Element' },
                ref    => [ qw( parentSignature ) ],
            },
        },

        # This class is the link between GeneSigDB and MAGE-TAB
        # models.
        'Bio::GeneSigDB::MAGETAB' => {
            bases  => [ 'Bio::GeneSigDB::Provenance' ],
            fields => {
                ref => [ qw( test reference investigation ) ],
            },
        },
    );

    push @{ $hashref->{'classes'} }, @genesig_classes;

    return $hashref;
}

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

=head1 NAME

Bio::GeneSigDB::Persistence - A Tangram-based object persistence
class for GeneSigDB.

=head1 SYNOPSIS

 use Bio::GeneSigDB::Persistence;
 my $db = Bio::GeneSigDB::Persistence->new({
    dbparams       => [ "dbi:mysql:$dbname", $user, $pass ],
 });

 $db->deploy();
 $db->connect();
 $db->insert( $object );

=head1 DESCRIPTION

This is a subclass of L<Bio::MAGETAB::Util::Persistence> which
provides additional object persistence mappings for classes specific
to the GeneSigDB model.

=head1 ATTRIBUTES

See the superclass for attribute documentation.

=head1 METHODS

See the superclass for method documentation.

=head1 SEE ALSO

L<Bio::MAGETAB::Util::Persistence>, Tangram

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
