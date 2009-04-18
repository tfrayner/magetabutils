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

package Bio::GeneSigDB::Signature;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Carp;

BEGIN { extends 'Bio::GeneSigDB' };

has 'name'                => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'species'             => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'notes'               => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_notes',
                               predicate  => 'has_notes',
                               required   => 0 );

has 'categories'          => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::GeneSigDB::Category]',
                               clearer    => 'clear_categories',
                               predicate  => 'has_categories',
                               required   => 0,
                               auto_deref => 1 );

has 'parentSignature'     => ( is         => 'rw',
                               isa        => 'Bio::GeneSigDB::Signature',
                               clearer    => 'clear_parentSignature',
                               predicate  => 'has_parentSignature',
                               required   => 0 );

has 'elements'            => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::GeneSigDB::Element]',
                               required   => 1,
                               auto_deref => 1 );

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

=pod

=head1 NAME

Bio::GeneSigDB::Signature - Core class used representing the gene signatures.

=head1 SYNOPSIS

 use Bio::GeneSigDB::Signature;

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head1 METHODS

=head1 SEE ALSO

L<Bio::GeneSigDB::PublishedSignature>

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
