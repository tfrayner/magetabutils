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

package Bio::GeneSigDB;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

sub BUILD {

    my ( $self, $params ) = @_;

    # Confirm that our parameters are all recognised.
    foreach my $param ( keys %{ $params } ) {
        my $getter = "get_$param";
        unless ( UNIVERSAL::can( $self, $getter ) ) {
            confess("ERROR: Unrecognised parameter: $param");
        }
    }

    # This is an abstract class; block direct instantiation.
    if ( blessed $self eq __PACKAGE__ ) {
        confess("ERROR: Attempt to instantiate abstract class " . __PACKAGE__);
    }

    return;
}

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

=pod

=head1 NAME

Bio::GeneSigDB - Abstract base class for all GeneSigDB classes.

=head1 SYNOPSIS

 use Bio::GeneSigDB;

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head1 METHODS

=head1 SEE ALSO

L<Bio::MAGETAB>

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
