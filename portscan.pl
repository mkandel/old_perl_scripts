#!/usr/bin/perl -w
# Copyright 1999 by Marc Kandel (marc@ttlc.net)
#
# This file was originally found on the net somewhere
#  and has been heavily modified by myself.  When I 
#  started on it it only took a hostname and optional
#  starting port.  I added the optional ending port.  I
#  also added the functionality to search the
#  /etc/services file for an entry matching that port.
use strict ;
use warnings ;

use IO::Socket;

my ($port, $end_port, $socket, $server);
my %services = () ;
if(@ARGV > 3 || @ARGV <=0){
    &usage ;
}
$server = $ARGV[0] || &usage;
$end_port = $ARGV[2] || 65000;

# &build_service_hash ;

for ( $port = ($ARGV[1] || 0) ; $port <= $end_port ; $port++ )
{
	if(	$socket = IO::Socket::INET->new	( 
	    PeerAddr => $server, 
	    PeerPort => $port, 
	    Proto => 'tcp' ))
    {
	    print "Connected on port $port ";
        if( defined($services{$port}) ){
            if( $port < 1000){
                print ":\t\t\t$services{$port}" ;
            } else {
                print ":\t\t$services{$port}" ;
            }
        } else {
#            print "Cannot resolve service name for port $port" ;
        }
	    print "\n" ;
	}
	else 
	{
#		print "$port failed\n";
	}
}

sub usage       
{
	print "Usage: portscan hostname [start port] [end port]\n";
	exit(0);
}

sub build_service_hash
{
#  if(open ( ES, "/private/etc/services" )){# || die "Could not open: /etc/services \n" ;
  open ( ES, "/private/etc/services" ) || die "Could not open: /etc/services \n" ;
	while (<ES>)
	{
        next if m/^#/ ; # Ignore comments
        next if m/^$/ ; # Ignore blank lines
		my ($service, $prt, $proto) = /(\S+)\s+(\S+)\/(\S+)/;		
        if( $proto eq "tcp"){
#            print "** Setting: \$services{'$prt'} = $service **\n" ;
            $services{$prt} = $service ;
#            print "** \$services{$prt} = $services{$prt} **\n" ;
        }
	}
	close (ES) ;
#  }
}
