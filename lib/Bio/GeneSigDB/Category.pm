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

package Bio::GeneSigDB::Category;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Carp;

use MooseX::Types::Moose qw( Str );

BEGIN { extends 'Bio::GeneSigDB' };

has 'name'                => ( is         => 'rw',
                               isa        => Str,
                               required   => 1 );

has 'parentCategory'      => ( is         => 'rw',
                               isa        => 'Bio::GeneSigDB::Category',
                               clearer    => 'clear_parentCategory',
                               predicate  => 'has_parentCategory',
                               required   => 0 );

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

=pod

=head1 NAME

Bio::GeneSigDB::Category - Class used to annotate signatures to
various user-defined categories.

=head1 SYNOPSIS

 use Bio::GeneSigDB::Category;

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head1 METHODS

=head1 SEE ALSO

L<Bio::GeneSigDB::Signature>

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
