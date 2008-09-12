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

package Bio::MAGETAB::Util::Writer::IDF;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use Carp;
use List::Util qw( max );

BEGIN { extends 'Bio::MAGETAB::Util::Writer::BaseClass' };

has 'magetab_object'     => ( is         => 'ro',
                              isa        => 'Bio::MAGETAB::Investigation',
                              required   => 1 );

sub write {

    my ( $self ) = @_;

    my $fh  = $self->get_filehandle();
    my $inv = $self->get_magetab_object();

    my @single = qw( title
                     description
                     date
                     publicReleaseDate );

    # FIXME check these field names against the spec!
    my @other_comments;
    my %multi = (
        'contacts' => [ sub { return ( [ 'Person Last Name',     map { $_->get_lastName()     } @_ ] ) },
                        sub { return ( [ 'Person First Name',    map { $_->get_firstName()    } @_ ] ) },
                        sub { return ( [ 'Person Mid Initials',  map { $_->get_midInitials()  } @_ ] ) },                        
                        sub { return ( [ 'Person Email',         map { $_->get_email()        } @_ ] ) },                        
                        sub { return ( [ 'Person Affiliation',   map { $_->get_affiliation()  } @_ ] ) },                        
                        sub { return ( [ 'Person Phone',         map { $_->get_phone()        } @_ ] ) },                        
                        sub { return ( [ 'Person Fax',           map { $_->get_fax()          } @_ ] ) },                        
                        sub { return ( [ 'Person Address',       map { $_->get_address()      } @_ ] ) },
                        sub { my @contacts = @_;
                              my @lists;
                              for ( my $i = 0; $i < scalar @contacts; $i++ ) {
                                  
                              push @lists (
                        'roles'               => 'Person Roles',  ],  # FIXME needs to return several arrayrefs: value, term source, term accession
                        sub { push @other_comments, map { $_->get_comments() } @_ },                        
        'factors' => [],
        'sdrfs' => [],
        'protocols' => [],
        'publications' => [],
        'termSources' => [],
        'designTypes' => [],
        'normalizationTypes' => [],
        'replicateTypes' => [],
        'qualityControlTypes' => [],
    );

    # We want a regular table, so figure out how many columns we will
    # need.
    my @objcounts = map {
        my $getter = "get_$_";
        scalar $inv->$getter;
    } keys %multi;
    $self->set_num_columns( 1 + max @objcounts );

    # Single elements are straightforward.
    foreach my $field ( @single ) {
        my $getter = "get_$field";
        $self->_write_line( $field, $inv->$getter );
    }

    # FIXME all the complicated stuff.
    while ( my ( $field, $subs ) = each %multi ) {
        my $getter = "get_$field";
        my @attrs = $inv->$getter;
        foreach my $sub ( @$subs ) {
            foreach my $lineref ( $sub->( @attrs ) ) {
                $self->_write_line( @{ $lineref } );
            }
        }
    }
    
    foreach my $comment ( $inv->get_comments(), @other_comments ) {
        my $field = sprintf("Comment[%s]", $comment->name());
        $self->_write_line( $field, $comment->value() );
    }
}

# Make the classes immutable. In theory this speeds up object
# instantiation for a small compilation time cost.
__PACKAGE__->meta->make_immutable();

no Moose;

1;
