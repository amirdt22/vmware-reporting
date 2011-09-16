#!/bin/perl 
# summary: report on vms in a host, use the -? flag to see the usage
# author: Amir Tahvildaran amirdt22@gmail.com
# warranty: none
# license: whatever

use Getopt::Std;

my %opts;

getopts('ldh?H:r:', \%opts);

my $help = $opts{'h'} || $opts{'?'};
help() if $help;

my $cmd = 'vmware-cmd';
my $host = $opts{'H'} || die;
my $stdcmd = "$cmd -H $host ";

my $report = $opts{'r'} || '.';


my $debug = $opts{'d'} || 0;

print "listing: $listing\n" if debug();
print "report: $report\n" if debug();


my $listing = vmrun("-l");
print $listing if $opts{'l'};

my @images = split(/\n/, $listing);
foreach my $image (@images) {
  if ($image =~ m/.*.vmx/) {
    next unless ($image =~ m/$report/);
    my $nice_name = $image;
    my ($state, $tools, $ip);

    print "image: $nice_name\t";

    $image = "'$image'";

    $state = vmrun("$image getstate");
    chomp($state);
    $state =~ s/getstate.. = //;
    print "$state\t";

    if($state =~ m/on/i){
    	$tools = vmrun("$image gettoolslastactive");
    	chomp($tools);
    	$tools =~ s/gettoolslastactive.. = //;
    	print "$tools\t";

	if($tools > 0) {#installed at some point
    		$ip = vmrun("$image getguestinfo ip");
    		chomp($ip);
    		$ip =~ s/getguestinfo.ip. = //;
    		print "$ip\t";
	}
    }
    
    print "\n";
  }
}


sub debug() {
  return $debug;
}

sub vmrun() {
  my $string = shift;
  return run("$stdcmd $string");
}

sub run() {
  my $string = shift;
  print "executing: $string \n" if debug();
  return `$string`;
}

sub help() {
  print "ahead of time you'll want to set up your credentials (credstore_admin.pl)\n";
  print "-H host : esxi host to connect to (required)\n";
  print "-r report : image to report on (partial/pattern ok) \n";
  print "-l : print listing of all images on host \n";
  print "-d : enable debugging messages \n";
  print "-h -? : print this message and exit \n";
  die;
}
