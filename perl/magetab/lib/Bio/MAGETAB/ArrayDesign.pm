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

package Bio::MAGETAB::ArrayDesign;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Bio::MAGETAB::Types qw(Uri);

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'name'                => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'accession'           => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_accession',
                               predicate  => 'has_accession',
                               required   => 0 );

has 'version'             => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_version',
                               predicate  => 'has_version',
                               required   => 0 );

has 'uri'                 => ( is         => 'rw',
                               isa        => 'Uri',
                               clearer    => 'clear_uri',
                               predicate  => 'has_uri',
                               coerce     => 1,
                               required   => 0 );

has 'provider'            => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_provider',
                               predicate  => 'has_provider',
                               required   => 0 );

has 'technologyType'      => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               clearer    => 'clear_technologyType',
                               predicate  => 'has_technologyType',
                               required   => 0 );

has 'surfaceType'         => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               clearer    => 'clear_surfaceType',
                               predicate  => 'has_surfaceType',
                               required   => 0 );

has 'substrateType'       => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               clearer    => 'clear_substrateType',
                               predicate  => 'has_substrateType',
                               required   => 0 );

has 'printingProtocol'    => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_printingProtocol',
                               predicate  => 'has_printingProtocol',
                               required   => 0 );

has 'sequencePolymerType' => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               clearer    => 'clear_sequencePolymerType',
                               predicate  => 'has_sequencePolymerType',
                               required   => 0 );

has 'designElements'      => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::DesignElement]',
                               auto_deref => 1,
                               clearer    => 'clear_designElements',
                               predicate  => 'has_designElements',
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
