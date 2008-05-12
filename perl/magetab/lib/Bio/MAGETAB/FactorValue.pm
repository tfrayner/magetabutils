# $Id$

package Bio::MAGETAB::FactorValue;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'measurement'         => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Measurement',
                               required   => 0 );

has 'term'                => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               required   => 0 );

has 'channel'             => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               required   => 0 );

has 'factor'              => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Factor',
                               required   => 1 );

no Moose;

1;
