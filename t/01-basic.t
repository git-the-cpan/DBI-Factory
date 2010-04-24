#!/usr/bin/env perl
use strict;
use warnings;
use DBI::Factory;
use Test::More;
use Test::Exception;
use FindBin qw/ $Bin /;

my ($factory, $dbh);
$ENV{DBIF_BASE} = undef; # to prevent your env to work

# invoking as a class method

# the most basic way
$dbh = DBI::Factory->get_dbh(
    config_base => "$Bin/conf/conf1",
    config_file => "dbm/test.yaml",
);
isa_ok( $dbh, "DBI::db" );
$dbh = undef;

# if failed to read config_file, it throws an exception
throws_ok {
    $dbh = DBI::Factory->get_dbh(
        config_base => "$Bin/conf/conf1",
        config_file => "dbm/unexisted.yaml",
    );
}
qr/failed to read config file/;
is($dbh, undef);

# seeing if config_file is assumed as an absolute path from '/'
# while config_base is not specified
$dbh = DBI::Factory->get_dbh(
    config_file => "$Bin/conf/conf2/dbm/test.yaml",
);
isa_ok( $dbh, "DBI::db" );
$dbh = undef;

# seeing if config_file is assumed as an absolute path from '/'
# even if config_base is specified
$dbh = DBI::Factory->get_dbh(
    config_base => "/must/not/be/existed",
    config_file => "$Bin/conf/conf2/dbm/test.yaml",
);
isa_ok( $dbh, "DBI::db" );
$dbh = undef;

# seeing if config_file is assumed as a relative path from current directory
# while config_base is not specified
$dbh = DBI::Factory->get_dbh(
    config_file => "t/conf/conf2/dbm/test.yaml",
);
isa_ok( $dbh, "DBI::db" );
$dbh = undef;

# seeing if $ENV{DBIF_BASE} works
$ENV{DBIF_BASE} = "$Bin/conf/conf3";
$dbh = DBI::Factory->get_dbh(
    config_file => "dbm/test.yaml",
);
isa_ok( $dbh, "DBI::db" );
$dbh = undef;

# seeing if a single string argument works
$dbh = DBI::Factory->get_dbh("dbm/test.yaml");
isa_ok( $dbh, "DBI::db" );
$dbh = undef;

# seeing if an empty but defined $ENV{DBIF_BASE} works
$ENV{DBIF_BASE} = q{};
$dbh = DBI::Factory->get_dbh(
    config_file => "$Bin/conf/conf3/dbm/test.yaml",
);
isa_ok( $dbh, "DBI::db" );
$ENV{DBIF_BASE} = undef;
$dbh = undef;

# if invoked with an invalid config file but RaiseError is off,
# it lives, returning undef
lives_ok {
    $dbh = DBI::Factory->get_dbh(
        config_base => "$Bin/conf/conf4",   # RaiseError => 0
        config_file => "dbm/something_is_wrong.yaml",
    );
};
is($dbh, undef);

# if invoked with an invalid config file and RaiseError is on,
# it dies
dies_ok {
    $dbh = DBI::Factory->get_dbh(
        config_base => "$Bin/conf/conf5",   # RaiseError => 1
        config_file => "dbm/something_is_wrong.yaml",
    );
};
is($dbh, undef);

# seeing if trailing slash in config_base is not harmful
$dbh = DBI::Factory->get_dbh(
    config_base => "$Bin/conf/conf1/",
    config_file => "dbm/test.yaml",
);
isa_ok( $dbh, "DBI::db" );
$dbh = undef;

# without "config_file", get_dbh takes args just like DBI->connect
$dbh = DBI::Factory->get_dbh(
    "dbi:DBM:f_dir=t/dbm",
    q{},
    q{},
    {
        RaiseError => 1,
        PrintError => 0,
    },
);
isa_ok( $dbh, "DBI::db" );
$dbh = undef;

# of course odd number of elements are also acceptable
$dbh = DBI::Factory->get_dbh(
    "dbi:DBM:f_dir=t/dbm",
    q{},
    q{},
);
isa_ok( $dbh, "DBI::db" );
$dbh = undef;

# thus, passing no args causes connection error
throws_ok {
    $dbh = DBI::Factory->get_dbh;
}
qr/Can't connect to data source/;
is($dbh, undef);

# invoking as an instance method

# the most basic way
$factory = DBI::Factory->new("$Bin/conf/conf1");
isa_ok( $factory, "DBI::Factory" );
$dbh = $factory->get_dbh("dbm/test.yaml");
isa_ok( $dbh, "DBI::db" );
$dbh = undef;
$factory = undef;

# if failed to read config_file, it throws an exception
$factory = DBI::Factory->new("$Bin/conf/conf1");
throws_ok {
    $dbh = $factory->get_dbh("dbm/unexisted.yaml");
}
qr/failed to read config file/;
$dbh = undef;

# seeing if config_file is assumed as an absolute path from '/'
# while config_base is not specified
$factory = DBI::Factory->new;
isa_ok( $factory, "DBI::Factory" );
$dbh = $factory->get_dbh("$Bin/conf/conf2/dbm/test.yaml");
isa_ok( $dbh, "DBI::db" );
$dbh = undef;
$factory = undef;

# seeing if $ENV{DBIF_BASE} works
$ENV{DBIF_BASE} = "$Bin/conf/conf3";
$factory = DBI::Factory->new;
isa_ok( $factory, "DBI::Factory" );
$dbh = $factory->get_dbh("dbm/test.yaml");
isa_ok( $dbh, "DBI::db" );
$dbh = undef;
$factory = undef;
$ENV{DBIF_BASE} = undef;

# if invoked with an invalid config file but RaiseError is off,
# it lives, returning undef
$factory = DBI::Factory->new("$Bin/conf/conf4");    # RaiseError => 0
lives_ok {
    $dbh = $factory->get_dbh("dbm/something_is_wrong.yaml");
};
is($dbh, undef);
$factory = undef;

# if invoked with an invalid config file and RaiseError is on,
# it dies
$factory = DBI::Factory->new("$Bin/conf/conf5");    # RaiseError => 1
dies_ok {
    $dbh = DBI::Factory->get_dbh("dbm/something_is_wrong.yaml");
};
is($dbh, undef);
$factory = undef;

# without "config_file", get_dbh takes args just like DBI->connect
$factory = DBI::Factory->new;
$dbh = $factory->get_dbh(
    "dbi:DBM:f_dir=t/dbm",
    q{},
    q{},
    {
        RaiseError => 1,
        PrintError => 0,
    },
);
isa_ok( $dbh, "DBI::db" );
$factory = undef;
$dbh = undef;

# of course odd number of elements are also acceptable
$factory = DBI::Factory->new;
$dbh = $factory->get_dbh(
    "dbi:DBM:f_dir=t/dbm",
    q{},
    q{},
);
isa_ok( $dbh, "DBI::db" );
$factory = undef;
$dbh = undef;

# thus, passing no args causes connection error
$factory = DBI::Factory->new;
throws_ok {
    $dbh = $factory->get_dbh;
}
qr/Can't connect to data source/;
is($dbh, undef);
$factory = undef;

done_testing;