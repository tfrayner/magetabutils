# $Id$

package Bio::MAGETAB::TermSource;

use Moose;

extends 'Bio::MAGETAB::BaseClass';

has 'name'                => ( is       => 'rw',
                               isa      => 'Str',
                               required => 1 );

has 'uri'                 => ( is       => 'rw',
                               isa      => 'Str',    # FIXME needs URI data type.
                               required => 0 );

has 'version'             => ( is       => 'rw',
                               isa      => 'Str',
                               required => 0 );

no Moose;

1;
