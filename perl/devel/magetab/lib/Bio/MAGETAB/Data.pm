# $Id$

package Bio::MAGETAB::Data;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::Node' };

# FIXME this is an abstract class; block direct instantiation.

has 'uri'                 => ( is       => 'rw',
                               isa      => 'Str',    # FIXME needs URI data type.
                               required => 1 );

no Moose;

1;
