# $Id$

package Bio::MAGETAB::DataMatrix;

use Moose;

extends 'Bio::MAGETAB::Data';

has 'rowIdentifierType'   => ( is       => 'rw',
                               isa      => 'Str',
                               required => 1 );

has 'matrixColumns'       => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::MatrixColumn]',
                               auto_deref => 1,
                               required   => 1 );

has 'matrixRows'          => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::MatrixRow]',
                               auto_deref => 1,
                               required   => 1 );

no Moose;

1;
