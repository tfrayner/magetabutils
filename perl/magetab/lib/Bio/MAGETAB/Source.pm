# $Id$

package Bio::MAGETAB::Source;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::Material' };

has 'providers'           => ( is         => 'rw',
                               isa        => 'ArrayRef[Str]',
                               auto_deref => 1,
                               clearer    => 'clear_providers',
                               predicate  => 'has_providers',
                               required   => 0 );

no Moose;

1;
