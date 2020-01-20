#!/usr/bin/perl -w
#
# multi_diff:
#	Author:	Marc Kandel (mkandel@aprisma.com)
#	Date  :	Tue Mar 13 15:33:55 EST 2001
#
# This script takes 2 directories as parameters
#	it will then take every file in the first 
#	directory and diff it with the same file in 
#	the second directory.  This is quite simplistic
#	and does very little error checking.
#

# Variable declarations
my ( $src_dir, $dst_dir, $file, $src_file, $dst_file );
my $sep = "\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n\n" ;

# usage function
sub usage{
	print "Usage: $0 <First Directory> <Second Directory>\n";
	exit( 0 );
}

# Parse commandline parameters
$src_dir = $ARGV[0] || &usage ;
$dst_dir = $ARGV[1] || &usage ;

# Force trailing slash here
$src_dir =~ s:/?$:/: ;
$dst_dir =~ s:/?$:/: ;

print $sep ;

foreach $file ( `ls -R $src_dir` )   {

	chomp( $file ) ;

	# Build complete file names
	$src_file = $src_dir . $file ;
	$dst_file = $dst_dir . $file ;

	# test for $src_file and $dst_file being
	#	regular files

	if ( -T $src_file && -T $dst_file ) {

		print $file . "\n" ;
#		print "\ndiff $src_file $dst_file\n" ;
		print `diff $src_file $dst_file` ;
		print $sep ;
	}
}
