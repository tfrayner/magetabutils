# Copyright 2008 Tim Rayner
# 
# This file is part of Bio::MAGETAB::Util.
# 
# Bio::MAGETAB::Util is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# Bio::MAGETAB::Util is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Bio::MAGETAB::Util.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id$

package Bio::MAGETAB::Util::Writer::SDRF;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Carp;

BEGIN { extends 'Bio::MAGETAB::Util::Writer::BaseClass' };

has 'magetab_object'     => ( is         => 'ro',
                              isa        => 'Bio::MAGETAB::SDRF',
                              required   => 1 );

sub _reassign_typed_layers {

    my ( $self, $layers, $is_assigned ) = @_;

    # We now check the types of all the columns in the various layers,
    # and reassign between layers where necessary/possible.
    for ( my $layernum = 0; $layernum < scalar @{ $layers }; $layernum++ ) {

        my $layer = $layers->[$layernum] ||= [];
        my $layertype;

        NODE:
        for ( my $rownum = 0; $rownum < scalar @{ $layer }; $rownum++ ) {

            my $node = $layer->[$rownum];

            # Gaps are allowed in this matrix.
            next NODE unless defined $node;

            my $type = blessed $node;

            # First node determines the layer type. Might be better to
            # put it to a vote FIXME.
            $layertype ||= $type;
            unless ( $layertype eq $type ) {

                # Cache the rest of the row.
                my @subsequent = map { $_->[ $rownum ] } @{ $layers }[ $layernum .. $#{ $layers } ];

                # Delete the node from the current layer.
                undef($layer->[$rownum]);

                # Reassign numbers, starting with the next
                # layer. FIXME at the moment all this does is
                # right-shift the rest of the current row, and
                # subsequent layers are then checked and reshifted as
                # necessary. It would be nice if we could be a bit
                # more intelligent about this.
                for ( my $outputnum = $layernum + 1; $outputnum <= scalar @{ $layers }; $outputnum++ ) {

                    my $node = shift @subsequent;

                    # A hole in the matrix gives us an opportunity to
                    # skip to the next node in the original layer
                    # (next row down). Hopefully this will help
                    # prevent creating too many unnecessary layers.
                    next NODE unless defined $node;

                    my $outputlayer = $layers->[$outputnum] ||= [];

                    # Move the node from the previous layer into this one.
                    $outputlayer->[ $rownum ] = $node;

                    # This may not be necessary, but if we ever want
                    # to re-use %is_assigned we'll need this.
                    $is_assigned->{ $node } = $outputnum;
                }
            }
        }
    }

    return $layers;
}

sub _assign_layers {

    my ( $self, $node_lists ) = @_;

    # Quick Schwarzian transform to list the rows in order, longest first.
    my @sorted_lists = map { $_->[1] }
                       reverse sort { $a->[0] <=> $b->[0] }
                       map { [ scalar @{ $_ }, $_ ] } @{ $node_lists };

    # Track layer assignments.
    my %is_assigned;

    # Reassign layers.
    my @layers;
    my $rownum = 0;
    foreach my $list ( @sorted_lists ) {
        my $index = 0;
        foreach my $node ( @{ $list } ) {

            # We must in theory check ALL input node layer values for
            # a given unassigned node, and select the
            # maximum. However, I think this works, but only because
            # we're dealing with the longest SDRFRow first.
            my $oldlayer = $is_assigned{ $node };
            if ( defined $oldlayer ) {
                $index = $oldlayer;
                $layers[ $index ][ $rownum ] = $node;
            }
            else {
                $layers[ $index ][ $rownum ] = $node;
                $is_assigned{ $node } = $index;
            }
            $index++;
        }
        $rownum++;
    }

    return $self->_reassign_typed_layers( \@layers, \%is_assigned );
}

sub _nodelists_from_rows {

    my ( $self, $rows ) = @_;

    # Return the node lists in the same order as the rows were passed.
    my @lists;
    foreach my $row ( @{ $rows }  ) {
        my @nodes = $row->get_nodes();

        # Quick and dirty way to get the starting node.
        my @input_nodes = grep { ! $_->has_inputEdges() } @nodes;
        my $num_inputs  = scalar @input_nodes;
        unless ( $num_inputs == 1 ) {
            croak("Error: Cannot identify a single starting node; "
                      . "SDRFRow has $num_inputs starting nodes.");
        }
        my $current = $input_nodes[0];

        # Add all the nodes in the SDRFRow, in order, by following the
        # node-edge graph.
        my @ordered_nodes;
        my %in_this_row = map { $_ => 1 } @nodes;
        while ( $current->has_outputEdges() ) {
            EDGE:
            foreach my $edge ( $current->get_outputEdges() ) {
                my $next = $edge->get_outputNode()
                    or croak("Error: Edge without an output node (this really shouldn't happen).");
                if ( $in_this_row{ $next } ) {
                    push @ordered_nodes, $current;
                    $current = $next;

                    # This assumes that no branching occurs within the
                    # SDRFRow; but then it shouldn't anyway.
                    last EDGE;
                }
            }
        }

        # This is now the last node.
        push @ordered_nodes, $current;

        # Store the row nodes in the return array.
        push @lists, \@ordered_nodes;
    }

    return \@lists;
}
##################################################################################################
sub _expand_layer {

    my ( $self, $layer ) = @_;

    # Given a layer arrayref, return an arrayref with n+1 arrayref
    # members (the extra line is the header) containing data ready to
    # print.

    my @output;

    # FIXME much to do here yet!
    

    return \@output;
}

sub _output_from_objects {

    my ( $self, $objects ) = @_;

    # All the objects passed in must be of the same type.
    my %check = map { blessed($_) => 1 } @{ $objects };
    unless ( ( scalar grep { defined $_ } values %check ) == 1 ) {
        croak("Error: Multiple object types in layer.");
    }

    my ( @values, @headings );
    foreach my $object ( @{ $objects } ) {
        my ( $obj_vals, $obj_headings ) = $self->_columns_from_object( $object );
        push @values, $obj_vals;
        push @headings, $obj_headings;
    }

    # FIXME interrogate the results. Make ragged lists regular, prune
    # lists to remove columns with no contents for any of the objects,
    # etc. etc.
}

sub _process_object {

    my ( $self, $object, $parent ) = @_;

    # Comments are so often used in the model that we just duck-type
    # to get at them.
    my $comment_headings = [];
    my $comment_values   = [];
    if ( UNIVERSAL::can( $object, 'get_comments' ) ) {

        # FIXME consider excluding ArrayDesign from this, as its
        # comments will typically be in the ADF anyway.
        my ( $comment_headings, $comment_values )
            = $self->_process_comments( $object->get_comments() );
    }

    # I imagine this will be controversial.
    my $namespace = join( ':', $object->get_namespace(), $object->get_authority() );

    return ( $comment_headings, $comment_values, $namespace );
}

sub _process_comments {

    my ( $self, @comments ) = @_;

    my (@headings, @values);
    foreach my $comm ( @comments ) {
        push @headings, sprintf("Comment [%s]", $comm->name());
        push @values,   $comm->value();
    }
    return( \@headings, \@values );
}

sub _process_controlled_term {

    my ( $self, $term, $parent ) = @_;

    unless ( UNIVERSAL::isa( $term, 'Bio::MAGETAB::ControlledTerm' ) ) {
        croak("Error: method requires a ControlledTerm object.");
    }

    # FIXME this list is probably incomplete. Links the parent class
    # and term category together to generate a column heading. Beware
    # inheritance if any of the parent classes are descended from any
    # of the others.
    my %dispatch = (

        # Parent class
        'Bio::MAGETAB::Material' => {

            # Term category;     Column heading.
            'MaterialType'    => 'Material Type',
            'LabelCompound'   => 'Label',
        },

        'Bio::MAGETAB::Assay' => {
            'TechnologyType'  => 'Technology Type',
        },
    );

    my ( @colnames, @colvalues );

    my $column;
    DISPATCH:
    foreach my $testclass ( keys %dispatch ) {
        if ( UNIVERSAL::isa( $parent, $testclass ) ) {
            $column = $dispatch{ $testclass }{ $term->get_category() };
            last DISPATCH if ( defined $column );
        }
    }

    # Store the main column heading.
    if ( defined $column ) {

        # Term category is in the dispatch table; we store a
        # column.
        push @colnames, $column;
    }
    elsif ( UNIVERSAL::isa( $parent, 'Bio::MAGETAB::Material' ) ) {

        # Not in dispatch table, but parent is a Material, implying
        # the term is a Characteristic.
        push @colnames, sprintf("Characterististics [%s]", $term->get_category() );
    }
    elsif ( UNIVERSAL::isa( $parent, 'Bio::MAGETAB::ParameterValue' ) ) {

        # Placeholder; I anticipate that this will change at some
        # point. Column heading would be "Parameter Value [<name of
        # Parameter>]" which is easily derived in the current
        # model. We could fix it now but then we'd be generating SDRFs
        # we can't actually parse.
        croak("Error: ParameterValue link to ControlledTerm not supported in MAGE-TAB v1.1");
    }
    elsif ( UNIVERSAL::isa( $parent, 'Bio::MAGETAB::DataFile' ) ) {

        # Do nothing. DataFile has DataFormat but this isn't actually
        # in the SDRF spec. We derive DataFormat from the actual data
        # files on every parse. We also have DataType but that just
        # determines raw vs derived and will be handled elsewhere.
    }
    else {
        confess("Probably not implemented yet FIXME.");
    }

    # Store the main value.
    push @colvalues, $term->get_value();

    # Now get the Term Source, Term Accession info. We fill these in
    # empty if they don't exist, and they get pruned out later on.
    my ( $tscols, $tsvals ) = $self->_process_dbentry( $term );
    push @colnames,  @$tscols;
    push @colvalues, @$tsvals;

    return \@colnames, \@colvalues;
}

sub _process_dbentry {

    my ( $self, $dbentry ) = @_;

    my @colnames = ('Term Source REF', 'Term Accession Number');

    my @colvalues;
    if ( my $ts = $dbentry->get_termSource() ) {
        push @colvalues, $ts->get_name(), $dbentry->get_accession();
    }
    else {

        # FIXME is it worth printing the accession if there's no term source?
        push @colvalues, undef, $dbentry->get_accession();
    }

    return( \@colnames, \@colvalues );
}

sub _process_array_design {

    my ( $self, $arraydesign ) = @_;

    my ( @colnames, @colvalues );
    if ( $arraydesign->has_uri() ) {
        push @colnames,  'Array Design File';
        push @colvalues, $arraydesign->get_uri();
    }
    else {
        push @colnames,  'Array Design REF';
        push @colvalues, $arraydesign->get_name();
    }

    # FIXME not sure about comments here (see also _process_object).
    my ( $commentcols, $commentvals, $namespace ) = $self->_process_object( $arraydesign );

    # Deal with Term Source, Term Accession...
    my ( $tsnames, $tsvals ) = $self->_process_dbentry( $arraydesign );
    push @colnames,  @$commentcols, @$tsnames;
    push @colvalues, @$commentvals, @$tsvals;
    
    return( \@colnames, \@colvalues );
}

sub _process_event {

    my ( $self, $obj, $colname ) = @_;

    my @colnames  = $colname;
    my @colvalues = $obj->get_name();

    my ( $commentcols, $commentvals, $namespace ) = $self->_process_object( $obj );
    push @colnames,  @{ $commentcols };
    push @colvalues, @{ $commentvals };

    return( \@colnames, \@colvalues );
}

sub _process_assay {

    my ( $self, $obj ) = @_;

    # Core stuff.
    my $type    = $obj->get_technologyType();
    my $namecol = ($type->get_value() =~ /\A hybridization \z/ixms
                ? 'Hybridization Name'
                : 'Assay Name');
    my ( $colnames, $colvalues ) = $self->_process_event( $obj, $namecol );

    # Other attributes.
    my ( $typecols, $typevals )   = $self->_process_controlled_term( $type, $obj );
    my ( $arraycols, $arrayvals ) = $self->_process_array_design( $obj->get_ArrayDesign(), $obj );

    # Put it all together in a parsable order.
    push @{ $colnames },  @{ $typecols }, @{ $arraycols };
    push @{ $colvalues }, @{ $typevals }, @{ $arrayvals };

    return( $colnames, $colvalues );
}

sub _process_scan {

    my ( $self, $obj ) = @_;

    return $self->_process_event( $obj, 'Scan Name' );
}

sub _process_normalization {

    my ( $self, $obj ) = @_;

    return $self->_process_event( $obj, 'Normalization Name' );
}

sub _process_data {

    my ( $self, $obj, $namecol ) = @_;

    my @colnames  = $namecol;
    my @colvalues = $obj->get_uri();

    my ( $commentcols, $commentvals, $namespace ) = $self->_process_object( $obj );
    push @colnames,  @{ $commentcols };
    push @colvalues, @{ $commentvals };

    return ( \@colnames, \@colvalues );
}

sub _process_datafile {

    my ( $self, $obj ) = @_;

    my $type    = $obj->get_type();
    my $colname = $type->get_value() eq 'image' ? 'Image File'
                                      : 'raw'   ? 'Array Data File'
                                                : 'Derived Array Data File';

    return $self->_process_data( $obj, $colname );
}

sub _process_datamatrix {

    my ( $self, $obj ) = @_;

    my $type    = $obj->get_type();
    my $colname = $type->get_value() eq 'raw' ? 'Array Data Matrix File'
                                              : 'Derived Array Data Matrix File';

    return $self->_process_data( $obj, $colname );
}

sub _process_provider {

    my ( $self, $prov, $parent ) = @_;

    return( [ 'Provider' ], [ $prov ] );
}

sub _process_material {

    my ( $self, $obj, $namecol ) = @_;

    my @colnames  = $namecol;
    my @colvalues = $obj->get_name();

    my ( $commentcols, $commentvals, $namespace ) = $self->_process_object( $obj );
    push @colnames,  @{ $commentcols };
    push @colvalues, @{ $commentvals };

    # FIXME MaterialType, Characteristics, Description, Measurements

    return ( \@colnames, \@colvalues );
}

sub _process_source {

    my ( $self, $obj ) = @_;

    my ( $colnames, $colvalues ) = $self->_process_material( $obj, 'Source Name' );

    my ( $provcols, $provvals ) = $self->_process_provider( $obj->get_providers(), $obj );

    push @{ $colnames },  @{ $provcols };
    push @{ $colvalues }, @{ $provvals };

    return( $colnames, $colvalues );
}

sub _columns_from_object {

    my ( $self, $object, $parent ) = @_;

    # This is the main entry point for the Node objects which have
    # been ordered into layers. This method flattens the objects into
    # two lists: column headings, and column values. No guarantee is
    # made that the lists for two objects of the same class will be
    # the same, however; Material Characteristics spring to mind as a
    # source of variability.

    unless ( UNIVERSAL::isa( $object, 'Bio::MAGETAB::Node' ) ) {
        croak("Error: method requires a Node object.");
    }

    my $class = blessed $object;
    $class =~ s/\A Bio::MAGETAB:: //xms;

    # FIXME don't forget we have to decide how to process namespace,
    # authority in here somewhere as well.

    # I think we're just processing Node objects here now.
    my %dispatch = (

        # Materials
        'Source'              => sub { $self->_process_source( @_ ) },

        # FIXME obviously these need changing:
        'Sample'              => sub { 'Sample Name' },
        'Extract'             => sub { 'Extract Name' },
        'LabeledExtract'      => sub { 'Labeled Extract Name' },

        # Events
        'Assay'               => sub { $self->_process_assay( @_ )         },
        'DataAcquisition'     => sub { $self->_process_scan( @_ )          },
        'Normalization'       => sub { $self->_process_normalization( @_ ) },

        # Data
        'DataFile'            => sub { $self->_process_datafile( @_ )      },
        'DataMatrix'          => sub { $self->_process_datamatrix( @_ )    },

#        'ProtocolApplication' => sub { 'Protocol REF' },
#        'FactorValue' => whatever.
    );

    my $col_sub;
    unless ( $col_sub = $dispatch{ $class } ) {
        confess(qq{Error: Node class "$class" is not mapped to an action.});
    }

    # All "_process_*" methods expect to receive both the object, and
    # its parent where applicable. Obviously for top-level Node
    # objects the parent isn't really meaningful. FIXME revisit this?
    my ( $headings, $values ) = $col_sub->( $object, $parent );

    # FIXME look at either inputEdges or outputEdges (but not both;
    # and check which corresponds to this SDRFRow!). This is going to
    # be a bit tricky and will probably need upstream code fixes.

    # Also we'll need to look at FactorValues; probably best to dump
    # them into the layers prior to calling this routine? FIXME

    return ( $headings, $values );
}

###################################################################################################
sub write {

    my ( $self ) = @_;

    # Create a defined matrix ($layers) indexed by columns and then
    # rows.
    my $sdrf       = $self->get_magetab_object();
    my @rows       = $sdrf->get_sdrfRows();
    my $node_lists = $self->_nodelists_from_rows( \@rows );
    my $layers     = $self->_assign_layers( $node_lists );

    # Generate the layer fragments to print out.
    my @outputs = map { $self->_output_from_objects( $_ ) } @{ $layers };

    # Assume the first layer is representative (as it *should* be).
    my $num_rows = scalar @{ $outputs[0] };

    # Merge each layer into an array of line arrayrefs. 
    my @lines;
    for ( my $i = 0; $i < $num_rows; $i++ ) {

        # FIXME need to handle undef values somewhere.
        $lines[ $i ] = [ map { @{ $_->[$i] } } @outputs ];
    }

    # Finally, dump everything to the file.
    my $max_column = max( map { scalar @{ $_ } } @lines );
    $self->set_num_columns( $max_column );
    foreach my $line ( @lines ) {
        $self->_write_line( $line );
    }

    return;
}

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

1;
