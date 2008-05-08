# $Id$

package Bio::MAGETAB::Factor;

use Moose;

extends 'Bio::MAGETAB::BaseClass';

has 'name'                => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'type'                => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               required   => 0 );

has 'factorValues'        => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::FactorValue]',
                               auto_deref => 1,
                               required   => 0 );

no Moose;

1;
