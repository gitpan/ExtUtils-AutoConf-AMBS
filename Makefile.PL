use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'ExtUtils::AutoConf',
    AUTHOR              => 'Alberto Simões <ambs@cpan.org>',
    VERSION_FROM        => 'lib/ExtUtils/AutoConf.pm',
    ABSTRACT_FROM       => 'lib/ExtUtils/AutoConf.pm',
    PL_FILES            => {},
    PREREQ_PM => {
		  'ExtUtils::CBuilder' => 0.07,
		  'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'ExtUtils-AutoConf-*' },
);
