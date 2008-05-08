# $Id$

package Bio::MAGETAB::Publication;

use Moose;

extends 'Bio::MAGETAB::BaseClass';

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
