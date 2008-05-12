# $Id$

package Bio::MAGETAB::Feature;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::DesignElement' };

has 'blockColumn'         => ( is       => 'rw',
                               isa      => 'Int',
                               required => 1 );

has 'blockRow'            => ( is       => 'rw',
                               isa      => 'Int',
                               required => 1 );

has 'column'              => ( is       => 'rw',
                               isa      => 'Int',
                               required => 1 );

has 'row'                 => ( is       => 'rw',
                               isa      => 'Int',
                               required => 1 );

has 'reporter'            => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Reporter',
                               required   => 1 );

no Moose;

1;
