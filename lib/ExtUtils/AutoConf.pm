package ExtUtils::AutoConf;
use ExtUtils::CBuilder;

use Config;

use File::Temp qw/tempfile/;
use File::Spec;

use warnings;
use strict;

=head1 NAME

ExtUtils::AutoConf - A module to implement some of AutoConf macros in pure perl.

=head1 VERSION

Version 0.01_001

=cut

our $VERSION = '0.01_001';

=head1 ABSTRACT

With this module I pretend to simulate some of the tasks AutoConf
macros do. To detect a command, to detect a library, etc.

=head1 SYNOPSIS

    use ExtUtils::AutoConf;

    ExtUtils::AutoConf->check_prog("agrep");
    ExtUtils::AutoConf->check_progs("agrep", "egrep", "grep");

    ExtUtils::AutoConf->check_prog_awk;
    ExtUtils::AutoConf->check_prog_egrep;

    ExtUtils::AutoConf->check_cc();

    ExtUtils::AutoConf->check_lib("ncurses", "tgoto");

=head1 FUNCTIONS

=head2 check_prog

This function checks for a program with the supplied name. In success
returns the full path for the executable;

=cut

sub check_prog {
  my $class = shift;
  # sanitize ac_prog
  my $ac_prog = _sanitize(shift());
  my $PATH = $ENV{PATH};
  my $p;
  for $p (split /$Config{path_sep}/,$PATH) {
    my $cmd = File::Spec->catfile($p,$ac_prog);
    return $cmd if -x $cmd;
  }
  return undef;
}

=head2 check_progs

This function takes a list of program names. Returns the full path for
the first found on the system. Returns undef if none was found.

=cut

sub check_progs {
  my $class = shift;
  my @progs = @_;
  for (@progs) {
    my $ans = check_prog($class, $_);
    return $ans if $ans;
  }
  return undef;
}


=head2 check_prog_awk

From the autoconf documentation,

  Check for `gawk', `mawk', `nawk', and `awk', in that order, and
  set output [...] to the first one that is found.  It tries
  `gawk' first because that is reported to be the best
  implementation.

Note that it returns the full path, if found.

=cut

sub check_prog_awk {
  my $class = shift;
  return check_progs(qw/$class gawk mawk nawk awk/);
}


=head2 check_prog_egrep

From the autoconf documentation,

  Check for `grep -E' and `egrep', in that order, and [...] output
  [...] the first one that is found.

Note that it returns the full path, if found.

=cut

sub check_prog_egrep {
  my $class = shift;

  my $grep;

  if ($grep = check_prog($class,"grep")) {
    my $ans = `echo a | ($grep -E '(a|b)') 2>/dev/null`;
    return "$grep -E" if $ans eq "a\n";
  }

  if ($grep = check_prog($class, "egrep")) {
    return $grep;
  }
  return undef;
}

=head2 check_cc

This function checks if you have a running C compiler.

=cut

sub check_cc {
  ExtUtils::CBuilder->have_compiler;
}

=head2 check_lib

This function is used to check if a specific library includes some
function. Call it with the library name (without the lib portion), and
the name of the function you want to test:

  ExtUtils::AutoConf->check_lib("z", "gzopen");

It returns 1 if the function exist, 0 otherwise.

=cut

sub check_lib {
  my $class = shift;
  my $lib = shift;
  my $func = shift;

  my $cbuilder = ExtUtils::CBuilder->new();

  return 0 unless $lib;
  return 0 unless $func;

  print STDERR "Trying to compile test program to check $func on $lib library...\n";

  my $LIBS = "-l$lib";
  my $conftest = <<"_ACEOF";
/* Override any gcc2 internal prototype to avoid an error.  */
#ifdef __cplusplus
extern "C"
#endif
/* We use char because int might match the return type of a gcc2
   builtin and then its argument prototype would still apply.  */
char $func ();
int
main ()
{
  $func ();
  return 0;
}
_ACEOF



  my ($fh, $filename) = tempfile( "testXXXXXX", SUFFIX => '.c');
  $filename =~ m!.c$!;
  my $base = $`;

  print {$fh} $conftest;
  close $fh;

  my $obj_file = eval{ $cbuilder->compile(source => $filename) };

  return 0 if $@;
  return 0 unless $obj_file;


  my $exe_file = eval { $cbuilder->link_executable(objects => $obj_file,
						   extra_linker_flags => $LIBS) };

  unlink $filename;
  unlink $obj_file if $obj_file;
  unlink $exe_file if $exe_file;

  return 0 if $@;
  return 0 unless $exe_file;

  return 1;
}

#
#
# Auxiliary funcs
#

sub _sanitize {
  # This is hard coded, and maybe a little stupid...
  my $x = shift;
  $x =~ s/ //g;
  $x =~ s/\///g;
  $x =~ s/\\//g;
  return $x;
}


=head1 AUTHOR

Alberto Simões, C<< <ambs@cpan.org> >>

=head1 NEXT STEPS

Although a lot of work needs to be done, this is the next steps I
intent to take.

  - detect flex/lex
  - detect yacc/bison/byacc
  - detect ranlib (not sure about its importance)

These are the ones I think not too much important, and will be
addressed later, or by request.

  - detect an 'install' command
  - detect a 'ln -s' command -- there should be a module doing
    this kind of task.

=head1 BUGS

A lot. Portability is a pain, and I just have a Linux machine.
B<<Patches welcome!>>.

Please report any bugs or feature requests to
C<bug-extutils-autoconf@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically
be notified of progress on your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

Michael Schwern

Ken Williams

=head1 COPYRIGHT & LICENSE

Copyright 2004-2005 Alberto Simões, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 SEE ALSO

ExtUtils::CBuilder(3)

=cut

1; # End of ExtUtils::AutoConf
