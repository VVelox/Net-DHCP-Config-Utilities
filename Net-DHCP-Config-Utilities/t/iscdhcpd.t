#!perl
use 5.006;
use strict;
use warnings;
use Test::More;
use Net::DHCP::Config::Utilities;

BEGIN {
    use_ok( 'Net::DHCP::Config::Utilities::INI_loader' ) || print "Bail out!\n";
}

my $dhcp_util=Net::DHCP::Config::Utilities->new;
my $ini_loader=Net::DHCP::Config::Utilities::INI_loader->new($dhcp_util);

my $worked=0;
my $generator;
eval{
	$worked=1;
};
ok( $worked eq '1', 'init') or diag('new failed with... '.$@);

done_testing(2);
