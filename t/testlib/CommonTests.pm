#!/usr/bin/env perl
#
# $Id$

use strict;
use warnings;

use Test::More;
use Test::Exception;

use base qw(Exporter);
our @EXPORT_OK = qw(test_class);

sub instantiate {

    my ( $class, $options ) = @_;

    my $obj = $class->new( %{ $options } );

    return $obj;
}

sub test_required_arg_instantiation {

    my ( $class, $required ) = @_;

    my @attr_pairs;
    while ( my ( $key, $value ) = each %{ $required } ) {
        push @attr_pairs, [ $key, $value ];
    }

    foreach my $index ( 0 .. $#attr_pairs ) {
        my @opts = @attr_pairs;
        splice( @opts, $index, 1 );
        my %attr = map { @{$_} } @opts;
        dies_ok( sub { instantiate( $class, \%attr ) },
                 qq{instantiation lacking required attribute "$attr_pairs[$index][0]" fails} );
    }

    return;
}

sub test_instantiation {

    # Test object instantiation under a number of conditions.
    my ( $class, $required, $optional, $bad ) = @_;

    my $obj;

    if ( scalar grep { defined $_ } values %$required ) {

        # Required attributes not set; should fail.
        dies_ok(  sub { $obj = instantiate( $class, $optional ) },
                  "instantiation with only optional args fails" );
    }
    else {

        # No required attributes, so this should pass.
        lives_ok( sub { $obj = instantiate( $class, $optional ) },
                  "instantiation with only optional args succeeds" );
    }

    # Attributes with bad data types; should fail.
    dies_ok(  sub { $obj = instantiate( $class, $bad ) },
              "instantiation with bad args fails" );

    # Test instantiation with $required minus each attribute, one at a
    # time, to confirm that they're really required.
    test_required_arg_instantiation( $class, $required );

    # Required attributes only; should pass.
    lives_ok( sub { $obj = instantiate( $class, $required ) },
              "instantiation with all required args succeeds" );

    # Check predicate method behaviour - before opt attr setting.
    while ( my ( $key, $value ) = each %{ $optional } ) {
        my $predicate = "has_$key";
        ok( ! $obj->$predicate, qq{and optional "$key" attribute predicate method agrees} );
    }

    # Construct a full instance as our return value.
    my $all = { %{ $optional }, %{ $required } };
    lives_ok( sub { $obj = instantiate( $class, $all      ) },
              "instantiation with all required and optional args succeeds" );

    # Check our fully-constructed object.
    ok( defined $obj,        'and returns an object' );
    ok( $obj->isa( $class ), 'of the correct class' );
    while ( my ( $key, $value ) = each %{ $all } ) {
        my $getter = "get_$key";
        is( $obj->$getter, $value, qq{with the correct "$key" attribute} );
    }

    # Check predicate method behaviour - after opt attr setting.
    while ( my ( $key, $value ) = each %{ $optional } ) {
        my $predicate = "has_$key";
        ok( $obj->$predicate, qq{and optional "$key" attribute predicate method agrees} );
    }

    return $obj;
}

sub test_update {

    my ( $obj, $required, $optional, $bad, $secondary ) = @_;

    # Check that updates work as we expect; correct update values first.
    while ( my ( $key, $value ) = each %{ $secondary } ) {
        my $setter = "set_$key";
        lives_ok( sub { $obj->$setter( $value ) }, qq{good "$key" attribute update succeeds} );
        my $getter = "get_$key";
        is( $obj->$getter, $value, 'and sets correct value' );
    }

    # Bad values next.
    while ( my ( $key, $value ) = each %{ $bad } ) {
        my $setter = "set_$key";
        dies_ok( sub { $obj->$setter( $value ) }, qq{bad "$key" attribute update fails} );
    }

    # Update with null values. Required attributes should fail.
    while ( my ( $key, $value ) = each %{ $required } ) {

        # In principle this should fail because the attributes are
        # required. In practice it's more likely they fail because we
        # simply don't provide a "clearer" method for such
        # attributes. Either way, success is bad.
        my $clearer = "clear_$key";
        dies_ok( sub { $obj->$clearer }, qq{clearing required "$key" attribute fails} );
    }
    
    # Optional attributes should be nullable.
    while ( my ( $key, $value ) = each %{ $optional } ) {

        # Clear the key
        my $clearer = "clear_$key";
        ok( $obj->can($clearer), qq{object can clear optional attribute "$key"} );
        lives_ok( sub { $obj->$clearer }, qq{clearing optional "$key" attribute succeeds} );

        # Check the value.
        my $getter = "get_$key";
        is( $obj->$getter, undef, 'and sets undef value' );

        # Check predicate method behaviour - after opt attr clearing.
        my $predicate = "has_$key";
        ok( ! $obj->$predicate, qq{and optional "$key" attribute predicate method agrees} );
    }

    return;
}

sub test_class {

    # Main entry point for the tests in this module.
    my ( $class, $required, $optional, $bad, $secondary ) = @_;

    my $instance = test_instantiation(
        $class,
        $required,
        $optional,
        $bad,
    );

    test_update(
        $instance,
        $required,
        $optional,
        $bad,
        $secondary,
    );

    # This needs to be a valid instance; further tests may be run.
    return $instance;
}
