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

BEGIN { extends 'Bio::MAGETAB::Util::Writer' };

sub draw {

    my ( $self ) = @_;

    my $fh = $self->get_filehandle();

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
        my $identifier;
        if ( UNIVERSAL::isa( $node, 'Bio::MAGETAB::Data' ) ) {
            $identifier = $node->get_uri();
        }
        else {
            $identifier = $node->get_name();
        }
        my $class = blessed( $node );

        # FIXME these obviously want to be elaborated upon.
        my $color = 'white';
        my $font  = 'courier';
            
        print $fh ( qq{"$node" [label="$identifier\\n$class",}
                  . qq{ color=black, shape=box, style=filled,}
                  . qq{ color="$color", fontname=$font];\n} );
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

1;
