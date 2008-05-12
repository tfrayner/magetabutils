# $Id$

package Bio::MAGETAB::DatabaseEntry;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'accession'           => ( is         => 'rw',
                               isa        => 'Str',
                               clearer    => 'clear_accession',
                               predicate  => 'has_accession',
                               required   => 0 );

has 'termSource'          => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::TermSource',
                               clearer    => 'clear_termSource',
                               predicate  => 'has_termSource',
                               required   => 0 );

no Moose;

1;
