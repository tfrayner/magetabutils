# $Id$

package Bio::MAGETAB::LabeledExtract;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

BEGIN { extends 'Bio::MAGETAB::Material' };

has 'label'               => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::ControlledTerm',
                               required   => 1 );

no Moose;

1;