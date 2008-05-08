# $Id$

package Bio::MAGETAB::MatrixRow;

use Moose;

extends 'Bio::MAGETAB::BaseClass';

has 'rowNumber'           => ( is         => 'rw',
                               isa        => 'Int',
                               required   => 1 );

has 'designElement'       => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::DesignElement',
                               required   => 1 );

no Moose;

1;
