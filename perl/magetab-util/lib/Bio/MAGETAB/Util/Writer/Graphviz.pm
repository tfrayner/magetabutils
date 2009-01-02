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

package Bio::MAGETAB::Util::Writer::Graphviz;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Carp;

has 'magetab'            => ( is         => 'rw',
                              isa        => 'Bio::MAGETAB',
                              required   => 1 );

has 'filehandle'         => ( is         => 'rw',
                              isa        => 'FileHandle',
                              coerce     => 1,
                              required   => 1 );

has 'font'               => ( is         => 'rw',
                              isa        => 'Str',
                              default    => sub { 'courier' },
                              required   => 1 );

sub draw {

    my ( $self ) = @_;

    my $fh = $self->get_filehandle();

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

    print $fh (<<'HEADER');
digraph "Experiment"{
rankdir=LR; 
rankspace=200
HEADER

    my @nodes = $self->get_magetab->get_nodes();
    my @edges = $self->get_magetab->get_edges();

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
            
            my $labname = $node->get_label()->get_value();
            $label .= qq{\\nLabel: $labname};

            while ( my ( $re, $col ) = each %label_color ) {
                if ( $labname =~ $re ) {
                    $color = $col;

                    # N.B. must allow the each loop to finish.
                }
            }
        }

        # Print out the node info.
        print $fh ( qq{"$node" [label="$label",}
                  . qq{ color=black, shape=box, style=filled,}
                  . qq{ fillcolor="$color", fontname=$font];\n} );
    }

    # Draw all the edges we know about. FIXME this wants fancying up
    # with protocol apps, parameters and the like.
    foreach my $edge ( @edges ) {
        my $input  = $edge->get_inputNode();
        my $output = $edge->get_outputNode();
        print $fh ( qq{"$input"->"$output"[color=black];\n});
    }

    # Close out the dot file.
    print $fh "}\n";
}

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

=head1 NAME

Bio::MAGETAB::Util::Writer::Graphviz - Visualization of MAGE-TAB objects.

=head1 SYNOPSIS

 use Bio::MAGETAB::Util::Writer::Graphviz;
 my $drawer = Bio::MAGETAB::Util::Writer::Graphviz->new({
    magetab    => $magetab_container,
    filehandle => $output_fh,
    font       => 'luxisr',
 });
 
 $drawer->draw();

=head1 DESCRIPTION

This is a simple visualization class for MAGE-TAB objects. It may be
developed further in future; at the moment, given a Bio::MAGETAB
container and a filehandle, it will just generate a '.dot' file which
can then be processed using the Graphviz "dot" application.

=head1 ATTRIBUTES

=over 2

=item magetab

The Bio::MAGETAB container containing the MAGE-TAB objects to
visualize. This is a required attribute. See L<Bio::MAGETAB> for more
information on this container class.

=item filehandle

The filehandle to use to output (i.e. the "dot" input file).

=item font

The font used for object labels in the output.

=back

=head1 METHODS

=over 2

=item draw

Generates output suitable for use with the Graphviz "dot" application.

=back

=head1 SEE ALSO

L<Bio::MAGETAB>

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 LICENSE

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
