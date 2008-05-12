# $Id$

package Bio::MAGETAB::ControlledTerm;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::DatabaseEntry' };

has 'value'               => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'category'            => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

no Moose;

1;
