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

     # We check our static image cache first, and generate a new PNG
     # if the file isn't found.
     my $static_paths = $c->config->{static}{include_path};
     my $cachefile    = $static_paths->[0]->file('static', 'graph_cache', "$id.png");
     my $imagedata;
     if ( ! -e $cachefile ) {
     
         require Bio::MAGETAB::Util::Writer::GraphViz;
         my $g = Bio::MAGETAB::Util::Writer::GraphViz->new(
             sdrfs => [ $object ],
         );

         my $image = $g->draw();
         $imagedata = $image->as_png();

         open ( my $fh, '>', $cachefile )
             or die("Error opening image cache $cachefile for writing: $!");

         print $fh $imagedata;
     }
     else {
         open ( my $fh, '<', $cachefile )
             or die("Error opening image cache $cachefile for reading: $!");

         $imagedata = join('', <$fh>);
     }

     $c->res->body( $imagedata );
     $c->res->content_type( 'image/png' );
}

=head1 AUTHOR

tfr23

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
