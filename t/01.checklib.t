# -*- cperl -*-

use Test::More tests => 2;

use ExtUtils::AutoConf;

diag("Ignore junk bellow.");

## OK, we really hope people have -lm around
ok(ExtUtils::AutoConf->check_lib("m", "atan"));
ok(!ExtUtils::AutoConf->check_lib("m", "foobar"));


