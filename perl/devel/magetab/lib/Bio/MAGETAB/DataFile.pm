# $Id$

package Bio::MAGETAB::DataFile;

use Moose;

extends 'Bio::MAGETAB::Data';

has 'format'              => ( is       => 'rw',
                               isa      => 'Str',
                               required => 1 );

no Moose;

1;
