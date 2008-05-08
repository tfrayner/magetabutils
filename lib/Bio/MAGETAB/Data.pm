# $Id$

package Bio::MAGETAB::Data;

use Moose;

extends 'Bio::MAGETAB::Node';

# FIXME this is an abstract class; block direct instantiation.

has 'uri'                 => ( is       => 'rw',
                               isa      => 'Str',    # FIXME needs URI data type.
                               required => 1 );

no Moose;

1;
