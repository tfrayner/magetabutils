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

package Bio::GeneSigDB::Element;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Carp;

BEGIN { extends 'Bio::GeneSigDB' };

has 'identifier'          => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'platform'            => ( is         => 'rw',
                               isa        => 'Bio::GeneSigDB::Platform',
                               required   => 1 );

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

=pod

=head1 NAME

Bio::GeneSigDB::Element - Class used to store individual gene or probe
identifiers, linking them to a given platform.

=head1 SYNOPSIS

 use Bio::GeneSigDB::Element;

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head1 METHODS

=head1 SEE ALSO

L<Bio::GeneSigDB::Signature>, L<Bio::GeneSigDB::Platform>

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
