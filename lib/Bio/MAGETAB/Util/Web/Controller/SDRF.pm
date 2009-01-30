package Bio::MAGETAB::Util::Web::Controller::SDRF;

use strict;
use warnings;
use parent 'Bio::MAGETAB::Util::Web::Controller::BaseClass';

=head1 NAME

Bio::MAGETAB::Util::Web::Controller::SDRF - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub new {

    my $class = shift;
    my $self  = $class->SUPER::new( @_ );

    $self->my_model_class( 'SDRF' );
    $self->my_container_class( 'Investigation' );

    return $self;
}

=head2 image

=cut

sub image : Local {
     my ( $self, $c, $id ) = @_;
     
     my $object = $c->model()->storage()->load( $id );
     unless ( $object ) {
         $c->flash->{error} = 'No such ' . $self->my_model_class() . '!';
         $c->res->redirect( $c->uri_for( $self->my_error_redirect() ) );
         $c->detach();
     }

     my $invs = $self->select_container_objects( $c, $object );

     require Bio::MAGETAB::Util::Writer::GraphViz;
     my $g = Bio::MAGETAB::Util::Writer::GraphViz->new(
         investigation => $invs->[0],
     );

     my $image = $g->draw();
     $c->res->body( $image->as_png() );
     $c->res->content_type( 'image/png' );
}

#<img src="[% c.uri_for("/sdrf/image", object) %]" />


=head1 AUTHOR

tfr23

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
