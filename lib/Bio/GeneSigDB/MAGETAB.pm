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

package Bio::GeneSigDB::MAGETAB;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Carp;

BEGIN { extends 'Bio::GeneSigDB::Provenance' };

has 'investigation'       => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Investigation',
                               required   => 1 );

has 'test'                => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::FactorValue',
                               required   => 1 );

has 'reference'           => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::FactorValue',
                               required   => 1 );

# FIXME we could profitably add a check that test and reference are
# actually used in the investigation (and aren't the same).

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

=pod

=head1 NAME

Bio::GeneSigDB::MAGETAB - Class linking a Signature to the evidence
from the MAGE-TAB model used to derive it.

=head1 SYNOPSIS

 use Bio::GeneSigDB::MAGETAB;

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head1 METHODS

=head1 SEE ALSO

L<Bio::GeneSigDB::Provenance>, L<Bio::MAGETAB::Investigation>, L<Bio::MAGETAB::FactorValue>

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
