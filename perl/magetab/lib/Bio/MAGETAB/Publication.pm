# $Id$

package Bio::MAGETAB::Publication;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::BaseClass' };

has 'title'               => ( is       => 'rw',
                               isa      => 'Str',
                               required => 0 );

has 'authorList'          => ( is       => 'rw',
                               isa      => 'Str',
                               required => 0 );

has 'pubMedID'            => ( is       => 'rw',
                               isa      => 'Str',
                               required => 0 );

has 'DOI'                 => ( is       => 'rw',
                               isa      => 'Str',
                               required => 0 );

has 'status'              => ( is       => 'rw',
                               isa      => 'Bio::MAGETAB::ControlledTerm',
                               required => 0 );

no Moose;

1;
