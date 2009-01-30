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

package Bio::MAGETAB::Util::Writer::GraphViz;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use GraphViz;
use Carp;

has 'investigation'      => ( is         => 'rw',
                              isa        => 'Bio::MAGETAB::Investigation',
                              required   => 1 );

has 'filehandle'         => ( is         => 'rw',
                              isa        => 'FileHandle',
                              coerce     => 1,
                              required   => 1 );

has 'font'               => ( is         => 'rw',
                              isa        => 'Str',
                              default    => sub { 'courier' },
                              required   => 1 );

has 'format'             => ( is         => 'rw',
                              isa        => 'Str',
                              required   => 1,
                              default    => 'png' );

has 'graphviz'           => ( is         => 'rw',
                              isa        => 'GraphViz',
                              required   => 1,
                              default    => sub { GraphViz->new(rankdir => 1); }, );

sub draw {

    my ( $self ) = @_;

    # This is our master colour table. Edit as necessary.
    my %color = (
        'white'        => '#ffffff',
        'light_yellow' => '#f8ff98',
        'red'          => '#ff5454',
        'green'        => '#81ff6d',
        'yellow'       => '#fff835',
        'light_blue'   => '#add9e6',
        'grey'         => '#c5c5c5',
        'mauve'        => '#9b7bff',
    );

    # Which of our master colours should be used for each dye?
    my %label_color = (
        qr/\A Cy3    \z/ixms => $color{'green'},
        qr/\A Cy5    \z/ixms => $color{'red'},
        qr/\A biotin \z/ixms => $color{'mauve'},
    );

    my $g = $self->get_graphviz();

    # Extract all the nodes and edges into two uniqued lists.
    my ( %node, %edge );
    foreach my $sdrf ( $self->get_investigation->get_sdrfs() ) {
        my @rownodes = map { $_->get_nodes() } $sdrf->get_sdrfRows();
        foreach my $node ( @rownodes ) {
            $node{ $node } = $node;
            foreach my $edge ( $node->get_inputEdges, $node->get_outputEdges ) {
                $edge{ $edge } = $edge;
            }
        }
    }
    my @nodes = values %node;
    my @edges = values %edge;

    # Create all the nodes. FIXME prettify by class, Label colour and
    # the like.
    foreach my $node ( @nodes ) {

        # Data nodes are identified by URI, everything else by Name.
        my $identifier;
        if ( UNIVERSAL::isa( $node, 'Bio::MAGETAB::Data' ) ) {
            $identifier = $node->get_uri();
        }
        else {
            $identifier = $node->get_name();
        }

        # What class is the node?
        my $class = blessed( $node );

        my $color = $color{'white'};
        my $font  = $self->get_font();

        # Start the label for the dot file. This will be expanded as we go. 
        my $label = qq{$identifier\\n$class};

        # Figure out LabelExtract colours.
        if ( UNIVERSAL::can( $node, 'get_label' ) ) {

            # Default colour for things lacking a recognised label.
            $color = $color{'grey'};

            my $labname = 'unknown';
            if ( my $cv = $node->get_label() ) {
                $labname = $cv->get_value();
            }
            $label .= qq{\\nLabel: $labname};

            while ( my ( $re, $col ) = each %label_color ) {
                if ( $labname =~ $re ) {
                    $color = $col;

                    # N.B. must allow the each loop to finish.
                }
            }
        }

        $g->add_node($node,
                     label     => $label,
                     color     => 'black',
                     shape     => 'box',
                     style     => 'filled',
                     fillcolor => $color,
                     fontname  => $font,);
    }

    # Draw all the edges we know about. FIXME this wants fancying up
    # with protocol apps, parameters and the like.
    foreach my $edge ( @edges ) {
        my $input  = $edge->get_inputNode();
        my $output = $edge->get_outputNode();
        $g->add_edge( $input => $output, color => 'black' );
    }

    # Print the output.
    my $method = 'as_' . $self->get_format();
    eval { print { $self->get_filehandle() } $g->$method };
    if ( $@ ) {
        croak("Error: Attempting to output graph using $method failed: $@");
    }
}

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

=head1 NAME

Bio::MAGETAB::Util::Writer::GraphViz - Visualization of MAGE-TAB objects.

=head1 SYNOPSIS

 use Bio::MAGETAB::Util::Writer::GraphViz;
 my $drawer = Bio::MAGETAB::Util::Writer::GraphViz->new({
    investigation => $investigation,
    filehandle    => $output_fh,
    font          => 'luxisr',
    format        => 'pdf',
 });
 
 $drawer->draw();

=head1 DESCRIPTION

This is a simple visualization class for MAGE-TAB objects. It may be
developed further in future; at the moment, given a
Bio::MAGETAB::Investigation object and a filehandle, it will just draw
an experimental design graph to the filehandle in one of a number of
formats.

=head1 ATTRIBUTES

=over 2

=item investigation

The Bio::MAGETAB::Investigation object to visualize. This is a
required attribute. See L<Bio::MAGETAB::Investigation> for more
information on this class.

=item filehandle

The filehandle to use to output (i.e. the "dot" input file).

=item font

The font used for object labels in the output.

=item format

The output format (required; default: png). This can in principle be
any of the formats supported by the GraphViz perl module $g->as_* methods.

=item graphviz

A GraphViz object. If this is not supplied, a default object will be
created; this attribute is provided so that you have a means of
accessing the underlying graph generation object.

=back

=head1 METHODS

=over 2

=item draw

Draws a graph in the specified format to the output filehandle.

=back

=head1 SEE ALSO

L<Bio::MAGETAB::Investigation>, GraphViz

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
