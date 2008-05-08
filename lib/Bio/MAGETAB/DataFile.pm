# $Id$

package Bio::MAGETAB::DataFile;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::Data' };

has 'format'              => ( is       => 'rw',
                               isa      => 'Str',
                               required => 1 );

no Moose;

1;
