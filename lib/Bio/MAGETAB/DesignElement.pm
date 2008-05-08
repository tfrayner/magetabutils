# $Id$

package Bio::MAGETAB::DesignElement;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

# FIXME this is an abstract class; block direct instantiation.

no Moose;

1;
