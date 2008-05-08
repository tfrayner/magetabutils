# $Id$

package Bio::MAGETAB::ProtocolParameter;

use Moose;

extends 'Bio::MAGETAB::BaseClass';

has 'name'                => ( is         => 'rw',
                               isa        => 'Str',
                               required   => 1 );

has 'protocol'            => ( is         => 'rw',
                               isa        => 'Bio::MAGETAB::Protocol',
                               weak_ref   => 1,
                               required   => 1,
                               trigger    => sub { my ( $self, $protocol ) = @_;
                                                   my @old = $protocol->parameters();
                                                   unless ( first { $_ eq $self } @old ) {
                                                       push @old, $self;
                                                       $protocol->parameters( \@old );
                                                   }
                                               } );

no Moose;

1;
