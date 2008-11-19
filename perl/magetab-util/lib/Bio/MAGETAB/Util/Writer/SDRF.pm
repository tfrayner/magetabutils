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

sub _column_heading_from_term {

    my ( $self, $object ) = @_;

    # FIXME this list is incomplete.
    my %dispatch = (
        'MaterialType'    => sub { 'Material Type' },
        'LabelCompound'   => sub { 'Label' },
        'TechnologyType'  => sub { 'Technology Type' },
    );

    my $colname;
    if ( my $sub = $dispatch{ $object->get_category() } ) {
        $colname = $sub->( $object );
    }
    else {
        $colname = sprintf("Characterististics [%s]", $object->get_category() );
    }

    return $colname;
}

sub _column_heading_from_object {

    my ( $self, $object ) = @_;

    my $class = blessed $object;
    $class =~ s/\A Bio::MAGETAB //xms;

    # FIXME this list is incomplete.
    my %dispatch = (
        'Source'              => sub { 'Source Name' },
        'Sample'              => sub { 'Sample Name' },
        'Extract'             => sub { 'Extract Name' },
        'LabeledExtract'      => sub { 'Labeled Extract Name' },

        # FIXME types need one more layer of indirection, through ControlledTerm
        'Assay'               => sub { $_[0]->get_technologyType() eq 'hybridization'
                                           ? 'Hybridization Name'
                                           : 'Assay Name' },
        'DataAcquisition'     => sub { 'Scan Name' },
        'Normalization'       => sub { 'Normalization Name' },
        'DataFile'            => sub { $_[0]->get_type() eq 'image' ? 'Image File'
                                           : 'raw' ? 'Array Data File'
                                           : 'Derived Array Data File' },
        'DataMatrix'          => sub { $_[0]->get_type() eq 'raw'
                                           ? 'Array Data Matrix File'
                                           : 'Derived Array Data Matrix File' },
        'ProtocolApplication' => sub { 'Protocol REF' },
        'ControlledTerm'      => sub { $self->_column_heading_from_term( @_ ) },
    );

    my $col_sub;
    unless ( $col_sub = $dispatch{ $class } ) {
        confess(qq{Error: Class "$class" is not mapped to a column heading.});
    }

    return $col_sub->( $object );
}

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
    my %check = map { blessed $_ => 1 } @{ $objects };
    unless ( scalar grep { defined $_ } values %check ) {
        croak("Error: Multiple object types in layer.");
    }

    my @values;
    foreach my $object ( @{ $objects } ) {
        push @values, $self->_attr_vals_from_object( $object );
    }

    # FIXME interrogate the results. Make ragged lists regular,
    # flatten the N-level array of arrays, prune lists to remove
    # columns with no contents for any of the objects, etc. etc.
}

sub _attr_vals_from_object {

    my ( $self, $object ) = @_;

    # For a given object return an arrayref of arrayrefs of the value(s)
    # for each attribute.

    # FIXME replace this sort function with a custom one that returns
    # "name" and "file" first. Or possibly "namespace" and "authority".
    my @attributes = map { $_->[1] }
                     sort { $a->[0] cmp $b->[0] }
                     map { [ $_->name(), $_ ] }
                         $object->meta->get_all_attributes();

    my @all_attr_values;

    ATTR:
    foreach my $attr ( @attributes ) {
        if ( my $getter = $attr->reader() ) {

            # FIXME recurse here to generate an N-level deep array of
            # arrays in which every leaf is a text string and every
            # node is an arrayref.
            my @retrieved = $object->$getter;
            my @this_attr_vals;
            foreach my $subvalue ( @retrieved ) {
                if ( UNIVERSAL::isa( $subvalue, 'Bio::MAGETAB::BaseClass' ) ) {

                    # FIXME we also need to recognise the SDRF objects
                    # which are actually defined in the IDF, and not
                    # follow those attributes beyond the Name
                    # attribute (creating a REF column).
                    push @this_attr_vals, $self->_attr_vals_from_object( $subvalue );
                }
                else {
                    push @this_attr_vals, $subvalue;
                }
            }

            push @all_attr_values, [ \@this_attr_vals ];
        }
    }

    return \@all_attr_values;
}

sub write {

    my ( $self ) = @_;

    # Create a defined matrix ($layers) indexed by columns and then
    # rows.
    my $sdrf       = $self->get_magetab_object();
    my @rows       = $sdrf->get_sdrfRows();
    my $node_lists = $self->_nodelists_from_rows( \@rows );
    my $layers     = $self->_assign_layers( $node_lists );

    # Generate the layer fragments to print out.
    my @outputs = map { $self->_expand_layer( $_ ) } @{ $layers };

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
