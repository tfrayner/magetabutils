# $Id$

package Bio::MAGETAB::DatabaseEntry;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'accession'           => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 0 );

has 'termSource'          => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::TermSource',
                               required   => 0 );

no Moose;

1;
