# -*- cperl -*-

use Test::More tests => 6;
use Config;
use ExtUtils::AutoConf;

ok(ExtUtils::AutoConf->check_prog("perl"));
ok(!ExtUtils::AutoConf->check_prog("hopingnobodyhasthiscommand"));

like(ExtUtils::AutoConf->check_progs("___perl___", "__perl__", "_perl_", "perl"), qr/perl$/);
is(ExtUtils::AutoConf->check_progs("___perl___", "__perl__", "_perl_"), undef);

AWK: {
  my $awk;
  skip "Not sure about your awk", 1 unless $Config{awk};
  ok($awk = ExtUtils::AutoConf->check_prog_awk);
  diag("Found AWK as $awk");
}

EGREP: {
  my $grep;
  skip "Not sure about your grep", 1 unless $Config{egrep};
  ok($grep = ExtUtils::AutoConf->check_prog_egrep);
  diag("Found EGREP as $grep");
}

