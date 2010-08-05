# $Id$

package Bio::MAGETAB::Util::DBIC::DB::ResultSet;

use Moose;

use List::Util qw(first);
use Storable qw(dclone);

BEGIN { extends 'DBIx::Class::ResultSet'; }

sub parent_class {
    confess("Error: stub method called in ResultSet superclass.");
}

sub new_result {

    my ( $self, $values ) = @_;

    $self->throw_exception( "new_result needs a hash" )
        unless (ref $values eq 'HASH');

    my ( %new_values, %parent_values );

    my $source = $self->result_source();
    while ( my ( $key, $value ) = each %$values ) {
        if ( first { $key eq $_ } $source->columns(), $source->relationships() ) {
            $new_values{ $key } = $value;
        }
        else {
            $parent_values{ $key } = $value;
        }
    }

    my $parent_class = $self->result_class->parent_class();
    my $parent = $source->schema->resultset($parent_class)->create( \%parent_values );

    $new_values{ 'id' } = $parent->id();

    $self->SUPER::new_result( \%new_values );
}

sub find {

    my ( $self, @args ) = @_;

    my %attrs = ( @args > 1 && ref $args[$#args] eq 'HASH' ? %{ pop(@args) } : () );

    # Only hashref queries need fixing; we're not going to support the
    # deprecated key => value usage of find().
    if (ref $args[0] eq 'HASH') {

        my ( $query, $new_attrs ) = $self->_create_join_condition( dclone $args[0] );

        # Rewrite the argument list.
        $args[0] = $query;

        # Merge new attrs with old; N.B. old join conditions will be
        # clobbered.
        @attrs{ keys %$new_attrs } = values %$new_attrs;
    }

    $self->SUPER::find( @args, \%attrs );
}

sub _create_join_condition {

    my ( $self, $original_query, $self_rel ) = @_;

    my $parent_rel = $self->_parent_relationship();

    my ( %query, %attrs, %parent_query );
    my $source = $self->result_source();
    while ( my ( $key, $value ) = each %{ $original_query } ) {
        if ( first { $key eq $_ } $source->columns(), $source->relationships() ) {
            if ( $self_rel ) {
                $query{ "$self_rel.$key" } = $value;
            }
            else {
                $query{ $key } = $value;
            }
        }
        else {
            $parent_query{ $key } = $value;
        }

        if ( scalar grep { defined $_ } values %parent_query ) {
            my $parent_rs = $source->schema
                                   ->resultset( $self->result_class->parent_class() );

            if ( $parent_rs->can('_create_join_condition') ) {
                my ( $new_parent_query, $parent_attrs ) =
                    $parent_rs->_create_join_condition( \%parent_query, $parent_rel );
                
                if ( exists $parent_attrs->{ 'join' } ) {

                    # Parent class contained a JOIN condition.
                    $attrs{ 'join' }{ $parent_rel } = $parent_attrs->{ 'join' };
                }
                else {

                    # We don't need to recurse all the way to the base class.
                    $attrs{ 'join' } = $parent_rel;
                }

                @query{ keys %$new_parent_query } = values %$new_parent_query;
            }
            else {

                # Parent must be base class; end of the recursion.
                $attrs{ 'join' } = $parent_rel;
                $query{ "$parent_rel.$key" } = $value;
            }
        }
    }

    return ( \%query, \%attrs );
}
    
sub _parent_relationship {

    my ( $self ) = @_;

    $self->_parent_class_to_relationship( $self->result_class->parent_class() );
}

sub _parent_class_to_relationship {

    # If we think this is slow enough we could Memoize it.
    my ( $self, $class ) = @_;

    my $rel = $class;

    $rel =~ s/([a-z])(?=[A-Z])/$1_/g;

    return( lc $rel . '_id' );
}

1;
