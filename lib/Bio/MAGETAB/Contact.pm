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

package Bio::MAGETAB::Contact;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Bio::MAGETAB::Types qw( Email );

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'lastName'            => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'firstName'           => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_firstName',
                               predicate  => 'has_firstName',
                               required   => 0 );

has 'midInitials'         => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_midInitials',
                               predicate  => 'has_midInitials',
                               required   => 0 );

has 'email'               => ( is         => 'rw',
                               isa        => 'Email',
                               clearer    => 'clear_email',
                               predicate  => 'has_email',
                               required   => 0 );

has 'organization'        => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_organization',
                               predicate  => 'has_organization',
                               required   => 0 );

has 'phone'               => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_phone',
                               predicate  => 'has_phone',
                               required   => 0 );

has 'fax'                 => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_fax',
                               predicate  => 'has_fax',
                               required   => 0 );

has 'address'             => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_address',
                               predicate  => 'has_address',
                               required   => 0 );

has 'roles'               => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::ControlledTerm]',
                               auto_deref => 1,
                               clearer    => 'clear_roles',
                               predicate  => 'has_roles',
                               required   => 0 );

has 'comments'            => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Comment]',
                               auto_deref => 1,
                               clearer    => 'clear_comments',
                               predicate  => 'has_comments',
                               required   => 0 );

__PACKAGE__->meta->make_immutable();

no Moose;

=pod

=head1 NAME

Bio::MAGETAB::Contact - MAGE-TAB contact class

=head1 SYNOPSIS

 use Bio::MAGETAB::Contact;

=head1 DESCRIPTION

This class is used to store information on contacts (i.e., the people
responsible for the experiment) in MAGE-TAB. See
L<Bio::MAGETAB::BaseClass> for superclass methods.

=head1 ATTRIBUTES

=over 2

=item lastName (required)

The contact's family name (data type: String).

=item firstName (optional)

The contact's given name (data type: String).

=item midInitials (optional)

The contact's middle initials (data type: String).

=item email (optional)

The contact's email address (data type: Email).

=item organization (optional)

The organization to which the contact is affiliated (data type:
String).

=item phone (optional)

The contact's telephone number (data type: String).

=item fax (optional)

The contact's FAX number (data type: String).

=item address (optional)

The street address for this contact (data type: String).

=item roles (optional)

A list of roles which this contact fulfills (data type:
Bio::MAGETAB::ControlledTerm).

=item comments (optional)

A list of user-defined comments for the contact (data type:
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