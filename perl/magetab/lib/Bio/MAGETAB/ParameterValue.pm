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

package Bio::MAGETAB::ParameterValue;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'measurement'         => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Measurement',
                               required   => 1 );

has 'comments'            => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Comment]',
                               auto_deref => 1,
                               clearer    => 'clear_comments',
                               predicate  => 'has_comments',
                               required   => 0 );

has 'parameter'           => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ProtocolParameter',
                               required   => 1 );

__PACKAGE__->meta->make_immutable();

no Moose;

=pod

=head1 NAME

Bio::MAGETAB::ParameterValue - MAGE-TAB parameter value class

=head1 SYNOPSIS

 use Bio::MAGETAB::ParameterValue;

=head1 DESCRIPTION

This class is used to describe the values of parameters within a
MAGE-TAB SDRF document. Note that as of the v1.1 MAGE-TAB
specification, parameter values can only be used with Measurements;
subsequent releases may allow ControlledTerms to be used as an
alternative. See L<Bio::MAGETAB::BaseClass> for superclass methods.

=head1 ATTRIBUTES

=over 2

=item measurement (required)

A measurement giving the actual value of the parameter (data type:
Bio::MAGETAB::Measurement).

=item parameter (required)

The Parameter to which the value applies. This links the value back to
the Protocol in question (data type: Bio::MAGETAB::ProtocolParameter).

=item comments (optional)

A list of user-defined comments for the parameter value (data type:
Bio::MAGETAB::Comment).

=back

=head1 METHODS

Each attribute has accessor (get_*) and mutator (set_*) methods, and
also predicate (has_*) and clearer (clear_*) methods where the
attribute is optional. Where an attribute represents a one-to-many
relationship the mutator accepts an arrayref and the accessor returns
an array.

=head1 SEE ALSO

L<Bio::MAGETAB::BaseClass>

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
