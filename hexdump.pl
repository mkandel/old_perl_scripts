#!/usr/bin/perl -w
use strict;
use Getopt::Std;
use vars qw($opt_p $opt_P $opt_c $opt_h $opt_d $opt_w $file $ma $mb $it $POS $COLS);

getopts("pPc:w:dh");
if ($opt_h) { usage(); }

# set columns
if ($opt_w) {
	$COLS = $opt_w;
} else {
	$COLS = 16;
}

# set prettyprinting on by default, turn off under some circumstances
my $prettyon = 1;

if ($^O eq 'MSWin32') {
	$prettyon = 0;
} elsif ($^O eq 'MacOS') {
	$prettyon = 0;
} elsif (! -t STDOUT) {
	$prettyon = 0;
}

# command line overrides
if ($opt_p) {
	$prettyon = 0;
} elsif ($opt_P) {
	$prettyon = 1;
}

if ($prettyon) {
	my $col = '32';
	if ($opt_c) { $col = $opt_c; }
	$ma = qq(\033[${col}m);
	$mb = qq(\033[m);
} else {
	$ma = $mb = '';
}

# get filename
$file = $ARGV[0] || '';

# make formatting string
my $format;
if ($opt_d) {
	$format = '%8.8u : ';
} else {
	$format = '%8.8x : ';
}
foreach (0..$COLS) {
	$format .= "%2s ";
	if ($_ == ($COLS/2)-1) { $format .= '   '; }
}
$format .= "\n";

$POS = 0;
header();

# Read the file and display
if (length $file) {
	open(FH, '<'.$file) or die("Can't open $file : $!");
} else {
	open(FH, '-') or die("Can't open STDIN apparently : $!");
}

while (read(FH, $it, $COLS)) {
	my @bits = map { escape($_) } split(//,$it);
	printf($format, $POS, @bits);
	$POS += $COLS;
}
print "\n";

############## END

sub header {
	return unless length($file);
	my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($file);
	print qq(
Filename   : $file
Logical EOF: $size
Permissions: ). sprintf('%o',$mode) . qq(
Links      : $nlink

);
}

sub escape {
	my $str = shift;
	$str =~ s/([\x00-\x1F\x7F-\xFF])/$ma . sprintf('%02X', ord($1)) . $mb/e;
	return $str;
}

sub usage {
	require Pod::Usage;
	Pod::Usage::pod2usage( '-verbose' => 2 );
}

=pod

=head1 NAME

hexdump.pl - a flexible program that shows you a file contents in an easy-to-read way

=head1 SYNOPSIS

	hexdump.pl [ -h ] [ -p | -P ] [ -d ] [ -c COLOURCODE ] [ -w NUM ] [ filename ]

	filename : the file you want to dump. Reads STDIN if no file is given.
	-h : show this help
	-p : force no prettyprinting, no colour or bold - e.g. use for piping to a file
	-P : force prettyprinting (i.e. colouring of hex codes) to be on
	-d : show byte offsets in decimal. Default is hex.
	-c nn : the VT100 colour code that you want special chars to come out as [31..37] - defaults to green, 32
	-w mm : how many bytes per row. Default is 16.

=head1 DESCRIPTION

This hex dump program shows printable characters (x20 to x7E) 'as-is', and everything
else as its hex code, and in a different colour by default.

It also shows file permissions, logical eof etc in a header.

You can alter the number of bytes shown per row - default is 16 bytes with a
gutter halfway across, as is usual

You can alter the colour given to the hex codes, or turn prettyprinting off
entirely

You can have the byte offsets in decomal or hex (the default)

You can read from a file or STDIN.

The program attempts to work out whether prettyprinting should be on or off
by default - use -p or -P to tell it explicitly.

=head1 EXAMPLE OUTPUT

In the following, the hex codes (the '0A' bytes here) were displayed on my terminal as
green - i.e. prettyprinting was on.

	Filename   : hexdump.pl
	Logical EOF: 3078
	Permissions: 100755
	Links      : 1

	00000000 :  #  !  /  u  s  r  /  l     o  c  a  l  /  b  i  n
	00000010 :  /  p  e  r  l     -  w    0A  #     $  I  d  :
	00000020 :  h  e  x  d  u  m  p  .     p  l  ,  v     1  .  2
	00000030 :     2  0  0  1  /  1  1     /  0  5     1  1  :  0
	00000040 :  1  :  4  1     p  i  e     r  s  k     E  x  p
	00000050 :  $ 0A 0A  u  s  e     s     t  r  i  c  t  ; 0A  u
	...

=head1 PREREQUISITES

Getopt::Std, Pod::Usage (for the usage/help message only) - or just put this
file through perldoc or whatever POD viewer you like.

=head1 COREQUISITES

None.

=begin comment

=pod OSNAMES

any

=pod SCRIPT CATEGORIES

UNIX/System_administration

=pod README

A flexible hex-dumping program that shows you a file contents in an easy-to-read way, with
clever pretty-printing, variable number of columns etc.

=end comment

=head1 VERSION

$Revision: 1.5 $

=cut

