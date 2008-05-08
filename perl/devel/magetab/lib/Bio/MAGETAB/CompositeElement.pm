# $Id$

package Bio::MAGETAB::CompositeElement;

use Moose;

extends 'Bio::MAGETAB::DesignElement';

has 'name'                => ( is       => 'rw',
                               isa      => 'Str',
                               required => 1 );

has 'databaseEntries'     => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::DatabaseEntry]',
                               auto_deref => 1,
                               required   => 0 );

has 'reporters'           => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Reporter]',
                               auto_deref => 1,
                               required   => 0 );

has 'comments'            => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Comment]',
                               auto_deref => 1,
                               required   => 0 );

no Moose;

1;
