#!/usr/bin/env perl
#
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
# $Id: 001_load.t 1026 2008-08-11 23:23:18Z tfrayner $
#
# t/001_load.t - check module loading

use strict;
use warnings;

use Test::More qw(no_plan);
use Test::Exception;

use Bio::MAGETAB;

BEGIN {
    use_ok( 'Bio::MAGETAB::Util::Reader::Builder' );
}

sub confirm_method {

    my ( $builder, $method, $generated_class, $attrs, $bad_attrs ) = @_;

    my $getter  = "get_$method";
    my $creator = "create_$method";
    my $finder  = "find_or_create_$method";

    dies_ok( sub{ $builder->$getter( values %{ $attrs } ) },
             qq{builder getter method doesn't find non-existent $generated_class} );

    my $obj;
    lives_ok( sub{ $obj = $builder->$creator( $attrs ) },
              qq{builder $generated_class create method succeeds} );

    ok( defined $obj, qq{and returns an object} );
    ok( $obj->isa( $generated_class ), qq{of the correct class} );

    my $obj2;
    lives_ok( sub{ $obj2 = $builder->$finder( $attrs ) },
              qq{builder $generated_class find_or_create method succeeds} );

    ok( defined $obj2, qq{and returns an object} );
    ok( $obj2->isa( $generated_class ), qq{of the correct class} );

    ok( $obj eq $obj2, qq{that is the same object generated by the create method} );

    my $obj3 = $builder->$creator( $attrs );
    ok( $obj ne $obj3,
        qq{builder create method correctly generates an entirely new instance} );

    my $obj4;
    lives_ok( sub{ $obj4 = $builder->$getter( values %{ $attrs } ) },
             qq{builder getter method finds generated $generated_class} );

    ok( $obj3 eq $obj4,
        qq{and the found object is the latest to be instantiated} );
}

# Dummy values for use in tests.
my $dummy_cv = Bio::MAGETAB::ControlledTerm->new(
    'category' => 'test category',
    'value'    => 'test value',
);

# Hash specifying the tests themselves.
# FIXME this is woefully incomplete.
my %test = (
    'array_design'      => { 'class'  => 'Bio::MAGETAB::ArrayDesign',
                             'attrs'  => { 'name' => 'test name' },
                             'unused' => [ 'not a name' ],
                         },
    'assay'             => { 'class'  => 'Bio::MAGETAB::Assay',
                             'attrs'  => { 'name'           => 'test name',
                                           'technologyType' => $dummy_cv },
                             'unused' => [ 'not a name' ],
                         },
    # FIXME I suspect the comment methods may be hideously awry. This API may need changing.
#    'comment'           => { 'class'  => 'Bio::MAGETAB::Comment',
#                             'attrs'  => { 'name'  => 'test name',
#                                           'value' => 'test value' },
#                             'unused' => [ 'not a name', 'not a value' ],
#                         },
    'composite_element' => { 'class'  => 'Bio::MAGETAB::CompositeElement',
                             'attrs'  => { 'name' => 'test name' },
                             'unused' => [ 'not a name' ],
                         },
    'contact'           => { 'class'  => 'Bio::MAGETAB::Contact',
                             'attrs'  => { 'lastName'    => 'last name',
                                           'firstName'   => 'first name',
                                           'midInitials' => 'mid initials' },
                             'unused' => [ 'a', 'b', 'c' ],
                         },
    'controlled_term'   => { 'class'  => 'Bio::MAGETAB::ControlledTerm',
                             'attrs'  => { 'category' => 'test cat',
                                           'value'    => 'test value' },
                             'unused' => [ 'x', 'y' ],
                   },
    'data_acquisition'  => { 'class'  => 'Bio::MAGETAB::DataAcquisition',
                             'attrs'  => { 'name' => 'test name' },
                             'unused' => [ 'not a name' ],
                         },
#    '' => { 'class'  => 'Bio::MAGETAB::',
#                       'attrs'  => { '' => '' },
#                       'unused' => [ '' ],
#                   },
    'publication' => { 'class'  => 'Bio::MAGETAB::Publication',
                       'attrs'  => { 'title' => 'test title' },
                       'unused' => [ 'not a title' ],
                   },
);

# FIXME we may want to test more instantiation options.
my $builder;
lives_ok( sub{ $builder = Bio::MAGETAB::Util::Reader::Builder->new({
    namespace => 'test_namespace',
    authority => 'test_authority',
}) }, q{Object constructor succeeds} );
ok( defined $builder, q{and returns an object} );
ok( $builder->isa('Bio::MAGETAB::Util::Reader::Builder'), q{of the correct class} );

while ( my ( $method, $data ) = each %test ) {

    confirm_method( $builder, $method, $data->{'class'}, $data->{'attrs'} );

    my $getter = "get_$method";
    dies_ok( sub{ $builder->$getter( @{ $data->{'unused'} } ) },
             qq{builder still fails to find non-existent object} );
}