# $Id$

package Bio::MAGETAB::Comment;

use Moose;

extends 'Bio::MAGETAB::BaseClass';

has 'name'                => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'value'               => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

no Moose;

1;
