#!/usr/bin/perl
# wgrep - windowed grep utility

$before = 1 ; $after = 1 ;
$show_stars = 0 ;
$show_nums = 0 ;
$sep = "----------\n" ;
$show_fname = 1 ;
$show_sep = 1 ;

# loop until argument DOESN'T begin with a "-"
while ( $ARGV[0] =~ /^-(\w)(.*)/ )
{
  $arg = $1 ;
  # Perl's fake case statement ... one drawback to perl
  if ( $arg eq "s" ) { $show_stars = 1 ; }
  elsif ( $arg eq "n" ) { $show_nums = 1 ; }
  elsif ( $arg eq "m" ) { $show_fname = 0 ; }
  elsif ( $arg eq "d" ) { $show_sep = 0 ; }
  elsif ( $arg eq "p" ) { $before = 0 ; $after = 0 ; }
  elsif ( $arg eq "W" ) { $before = 0 ; $after = 0 ; }
  elsif ( $arg eq "h" ) { &usage( "" ) ; }
  elsif ( $arg eq "w" )
  {
    # parse 2nd matched section at colon
    # into default array @_
    split( /:/,$2 ) ;
    $before = $_[0] if $_[0] ne '' ;
    $after = $_[1] if $_[1] ne '' ;
  }
  else { &usage( "wgrep: invalid option: $ARGV[0]" ) ; }

  shift;    # next $ARGV
}

&usage( "missing regular expression" ) if ! $ARGV[0] ;
$regexp = $ARGV[0] ;
shift;
$regexp =~ s,/,\\/,g ;    # "/" ==> "\/"

# if no files specified ... use STDIN
if ( ! $ARGV[0] ) { $ARGV[0] = "STDIN" }

LOOP:       # hmmm smells like a "thou shalt not" goto ...
foreach $file ( @ARGV)
{
  if ( $file ne "STDIN" && ! open( NEWFILE, $file ) )
  {
    print STDERR "Can't open file $file ... skipping it.\n" ;
    next LOOP ;     # see i knew it was a goto!!!!!!
  }

  # initialize some stuff
  $fhandle = $file eq "STDIN" ? STDIN : NEWFILE ;
  $lnum = "00000" ;
  $nbef = 0 ; $naft = 0 ;
  $matched = 0 ; $matched2 = 0 ;
  &clear_buf( 0 ) if $before > 0;

  while ( <$fhandle> )      # loop over lines in the file
  {
    $lnum++ ;          # increment line num
    if ( $matched )        # we're printing the current window
    {
      # This can't execute until $matched is set below

      if ( $_ =~ /$regexp/ )  # if current line matches pattern ...
      {
        $naft = 0 ;      #   reset the after window count
        &print_info( 1 ) ;  #  print preliminary stuff
        print $_ ;      #  and print the line
      }
      else          # current line does not match
      {
        if ( $after > 0 && ++$naft <= $after )
        {
          &print_info( 0 ) ;
          print $_ ;
        }
        else
        {
          $matched = 0 ;  # after window is done
          $naft = 0 ;    # reset
          # save line in buffer for future matches
          push( @line_buf, $_ ) ;
          $nbef++ ;
        }
      }
    }

    # this seems to be the real work here

    else            # looking for a match
    {
      if ( $_ =~ /$regexp/ )   # we found one
      {
        $matched = 1 ;    # set flag
        # print file and/or section seperator(s)
        print $sep if $matched2 && $nbef > $before && $show_sep && $show_fname ;
        print "====== $file ======\n" if ! $matched2++ && $show_fname ;
        # print/clear buf & reset before counter
        &clear_buf( 1 ) if $before > 0; $nbef = 0 ;
        &print_info( 1 ) ; print $_ ;
      }
      else
      {
        # pop off oldest in buf and add current
        shift( @line_buf ) if $nbef >= $before ;
        push( @line_buf, $_ ) ; $nbef++ ;
      }
    }
  }      # closes while
}        # closes foreach

exit ; # end of script proper

# next come the subroutines
sub print_info
{
  print $_{0} ? "* " : "  " if $show_stars ;
  print $lnum," " if $show_nums ;
}

sub usage
{
  print STDERR $_[0],"\n" if $_[0] ;
  print STDERR "Usage: wgrep [-nsmdwpWh] regexp <file1> [file2]...\n" ;
  exit ; 
}

sub clear_buf
{
  # arg says wether bef or aft
  $print_flag = $_[0] ;
  $i = 0 ; $j = 0 ;
  if ( $print_flag )
  {
    if ( $show_nums )
    {
      $target = $lnum - ( $#line_buf + 1 ) ;
      $lnum = "00000" ;
      while ( $i++ < $target ) { ++$lnum ; }
    }
    while ( $j <= $#line_buf )
    {
      &print_info( 0 ) ;
      print $line_buf[$j++] ;
      $lnum++ if $show_nums ;
    }
  }
  @line_buf = () ;
}
