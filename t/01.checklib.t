# -*- cperl -*-

use Test::More tests => 2;

use ExtUtils::AutoConf;

diag("\n\nIgnore junk bellow.\n\n");

## OK, we really hope people have -lm around
ok(ExtUtils::AutoConf->check_lib("m", "atan"));
ok(!ExtUtils::AutoConf->check_lib("m", "foobar"));


