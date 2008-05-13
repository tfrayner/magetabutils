# $Id$

package Bio::MAGETAB::Assay;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::Event' };

has 'arrayDesign'         => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ArrayDesign',
                               clearer    => 'clear_arrayDesign',
                               predicate  => 'has_arrayDesign',
                               required   => 0 );

has 'technologyType'      => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               required   => 1 );

no Moose;

1;