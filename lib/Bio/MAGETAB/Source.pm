# $Id$

package Bio::MAGETAB::Source;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::Material' };

has 'providers'           => ( is         => 'rw',
                               isa        => 'ArrayRef[Bio::MAGETAB::Contact]',
                               auto_deref => 1,
                               required   => 0 );

no Moose;

1;
