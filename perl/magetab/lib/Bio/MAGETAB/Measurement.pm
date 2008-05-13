# $Id$

package Bio::MAGETAB::Measurement;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'type'                => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'value'               => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_value',
                               predicate  => 'has_value',
                               required   => 0 );

has 'minValue'            => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_minValue',
                               predicate  => 'has_minValue',
                               required   => 0 );

has 'maxValue'            => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_maxValue',
                               predicate  => 'has_maxValue',
                               required   => 0 );

has 'unit'                => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               clearer    => 'clear_unit',
                               predicate  => 'has_unit',
                               required   => 0 );

no Moose;

1;
