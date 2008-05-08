# $Id$

package Bio::MAGETAB::Event;

use Moose;

extends 'Bio::MAGETAB::BaseClass';

# FIXME this is an abstract class; block direct instantiation.

has 'name'                => ( is       => 'rw',
                               isa      => 'Str',
                               required => 1 );

no Moose;

1;
