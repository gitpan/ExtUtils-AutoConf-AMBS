package ExtUtils::AutoConf;

use Config;

use File::Temp qw/tempfile/;

use warnings;
use strict;

=head1 NAME

ExtUtils::AutoConf - A module to implement some of AutoConf macros in pure perl.

=head1 VERSION

Version 0.00_002

=cut

our $VERSION = '0.00_002';

=head1 ABSTRACT

With this module I pretend to simulate some of the tasks AutoConf
macros do. To detect a command, to detect a library, etc.

=head1 SYNOPSIS

    use ExtUtils::AutoConf;

    ExtUtils::AutoConf->check_cc();

    ExtUtils::AutoConf->check_lib("ncurses", "tgoto");

=head1 FUNCTIONS

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

  ## These variables should not be hardcoded.
  my $CC = $Config{cc};
  my $EXT = $Config{_exe};

  my ($fh, $filename) = tempfile( "testXXXXXX", SUFFIX => '.c');
  $filename =~ m!.c$!;
  my $base = $`;

  print {$fh} $conftest;
  close $fh;

  print STDERR " + Compile\n";
  system("$CC -c $filename");
  if ($?) {
    unlink $filename;
    return 0;
  }

  print STDERR " + Link\n";
  system("$CC -o conftest$EXT $base.o $LIBS");

  unlink $filename;
  unlink "$base.o";
  unlink "conftest$EXT";

  return 0 if $?;

  return 1;
}

=head1 AUTHOR

Alberto Simões, C<< <ambs@cpan.org> >>

=head1 BUGS

A lot. Portability is a pain, and I just have a Linux machine.
B<<Patches welcome>>.

Please report any bugs or feature requests to
C<bug-extutils-autoconf@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically
be notified of progress on your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

Michael Schwern

Ken Williams

=head1 COPYRIGHT & LICENSE

Copyright 2004 Alberto Simões, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 SEE ALSO

ExtUtils::CBuilder(3)

=cut

1; # End of ExtUtils::AutoConf
