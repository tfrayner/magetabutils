# $Id$

package Bio::MAGETAB::BaseClass;

use Moose;

# These dumps don't currently work with the circular referencing we're
# allowing (Data::Dumper still works though).

#use MooseX::Storage;

#with Storage('format' => 'Storable');

no Moose;

1;
