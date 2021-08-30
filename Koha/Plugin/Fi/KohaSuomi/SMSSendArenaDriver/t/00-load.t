#!perl -T
use Modern::Perl;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'SMS::Send::Arena::Driver' ) || print "Bail out!\n";
}

diag( "Testing SMS::Send::Arena::Driver $SMS::Send::Arena::Driver::VERSION, Perl $], $^X" );