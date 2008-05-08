# $Id$

package Bio::MAGETAB::MatrixColumn;

use Moose;

extends 'Bio::MAGETAB::BaseClass';

has 'columnNumber'        => ( is         => 'rw',
                               isa        => 'Int',
                               required   => 1 );

has 'quantitationType'    => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               required   => 1 );

has 'referencedNodes'     => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Node]',
                               auto_deref => 1,
                               required   => 1 );

no Moose;

1;
