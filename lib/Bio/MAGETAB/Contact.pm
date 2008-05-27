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

1;
