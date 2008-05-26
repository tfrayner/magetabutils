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

package Bio::MAGETAB::Investigation;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Bio::MAGETAB::Types qw(Date);

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'title'               => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'description'         => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_description',
                               predicate  => 'has_description',
                               required   => 0 );

has 'date'                => ( is         => 'rw',
                               isa        => 'Date',
                               clearer    => 'clear_date',
                               predicate  => 'has_date',
                               coerce     => 1,
                               required   => 0 );

has 'publicReleaseDate'   => ( is         => 'rw',
                               isa        => 'Date',
                               clearer    => 'clear_publicReleaseDate',
                               predicate  => 'has_publicReleaseDate',
                               coerce     => 1,
                               required   => 0 );

has 'contacts'            => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Contact]',
                               auto_deref => 1,
                               clearer    => 'clear_contacts',
                               predicate  => 'has_contacts',
                               required   => 0 );

has 'factors'             => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Factor]',
                               auto_deref => 1,
                               clearer    => 'clear_factors',
                               predicate  => 'has_factors',
                               required   => 0 );

has 'sdrfs'               => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::SDRF]',
                               auto_deref => 1,
                               clearer    => 'clear_sdrfs',
                               predicate  => 'has_sdrfs',
                               required   => 0 );

has 'protocols'           => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Protocol]',
                               auto_deref => 1,
                               clearer    => 'clear_protocols',
                               predicate  => 'has_protocols',
                               required   => 0 );

has 'publications'        => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Publication]',
                               auto_deref => 1,
                               clearer    => 'clear_publications',
                               predicate  => 'has_publications',
                               required   => 0 );

has 'termSources'         => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::TermSource]',
                               auto_deref => 1,
                               clearer    => 'clear_termSources',
                               predicate  => 'has_termSources',
                               required   => 0 );

has 'designTypes'         => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::ControlledTerm]',
                               auto_deref => 1,
                               clearer    => 'clear_designTypes',
                               predicate  => 'has_designTypes',
                               required   => 0 );

has 'normalizationTypes'  => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::ControlledTerm]',
                               auto_deref => 1,
                               clearer    => 'clear_normalizationTypes',
                               predicate  => 'has_normalizationTypes',
                               required   => 0 );

has 'replicateTypes'      => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::ControlledTerm]',
                               auto_deref => 1,
                               clearer    => 'clear_replicateTypes',
                               predicate  => 'has_replicateTypes',
                               required   => 0 );

has 'qualityControlTypes' => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::ControlledTerm]',
                               auto_deref => 1,
                               clearer    => 'clear_qualityControlTypes',
                               predicate  => 'has_qualityControlTypes',
                               required   => 0 );

has 'comments'            => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Comment]',
                               auto_deref => 1,
                               clearer    => 'clear_comments',
                               predicate  => 'has_comments',
                               required   => 0 );

no Moose;

1;
