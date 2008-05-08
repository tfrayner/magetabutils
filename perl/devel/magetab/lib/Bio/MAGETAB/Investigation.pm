# $Id$

package Bio::MAGETAB::Investigation;

use Moose;

extends 'Bio::MAGETAB::BaseClass';

has 'title'               => ( is       => 'rw',
                               isa      => 'Str',
                               required => 1 );

has 'description'         => ( is       => 'rw',
                               isa      => 'Str',
                               required => 0 );

has 'date'                => ( is       => 'rw',
                               isa      => 'Str',   # FIXME needs Date type
                               required => 0 );

has 'publicReleaseDate'   => ( is       => 'rw',
                               isa      => 'Str',   # FIXME needs Date type
                               required => 0 );

has 'contacts'            => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Contact]',
                               auto_deref => 1,
                               required   => 0 );

has 'factors'             => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Factor]',
                               auto_deref => 1,
                               required   => 0 );

has 'protocols'           => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Protocol]',
                               auto_deref => 1,
                               required   => 0 );

has 'publications'        => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Publication]',
                               auto_deref => 1,
                               required   => 0 );

has 'termSources'         => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::TermSource]',
                               auto_deref => 1,
                               required   => 0 );

has 'designTypes'         => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::ControlledTerm]',
                               auto_deref => 1,
                               required   => 0 );

has 'normalizationTypes'  => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::ControlledTerm]',
                               auto_deref => 1,
                               required   => 0 );

has 'replicateTypes'      => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::ControlledTerm]',
                               auto_deref => 1,
                               required   => 0 );

has 'qualityControlTypes' => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::ControlledTerm]',
                               auto_deref => 1,
                               required   => 0 );

has 'comments'            => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Comment]',
                               auto_deref => 1,
                               required   => 0 );

no Moose;

1;
