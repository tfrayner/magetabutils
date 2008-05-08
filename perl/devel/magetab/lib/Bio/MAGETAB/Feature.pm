# $Id$

package Bio::MAGETAB::Feature;

use Moose;

use List::Util qw(first);

extends 'Bio::MAGETAB::DesignElement';

has 'blockColumn'         => ( is       => 'rw',
                               isa      => 'Int',
                               required => 1 );

has 'blockRow'            => ( is       => 'rw',
                               isa      => 'Int',
                               required => 1 );

has 'column'              => ( is       => 'rw',
                               isa      => 'Int',
                               required => 1 );

has 'row'                 => ( is       => 'rw',
                               isa      => 'Int',
                               required => 1 );

# FIXME this trigger won't work correctly to remove features from
# previous reporters on update.
has 'reporter'            => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Reporter',
                               weak_ref   => 1,
                               required   => 1,
                               trigger    => sub { my ( $self, $reporter ) = @_;
                                                   my @old = $reporter->features();
                                                   unless ( first { $_ eq $self } @old ) {
                                                       push @old, $self;
                                                       $reporter->features( \@old );
                                                   }
                                               } );

no Moose;

1;
