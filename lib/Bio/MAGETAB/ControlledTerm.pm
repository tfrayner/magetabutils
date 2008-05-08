# $Id$

package Bio::MAGETAB::ControlledTerm;

use Moose;

extends 'Bio::MAGETAB::DatabaseEntry';

has 'value'               => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'category'            => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

no Moose;

1;
