# $Id$

package Bio::MAGETAB::Measurement;

use Moose;

extends 'Bio::MAGETAB::BaseClass';

has 'type'                => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'value'               => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 0 );

has 'minValue'            => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 0 );

has 'maxValue'            => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 0 );

has 'unit'                => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               required   => 0 );

no Moose;

1;
