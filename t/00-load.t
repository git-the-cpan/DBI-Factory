#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'DBI::Factory' ) || print "Bail out!
";
}

diag( "Testing DBI::Factory $DBI::Factory::VERSION, Perl $], $^X" );
