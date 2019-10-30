#!perl
use 5.006;
use strict;
use warnings;
use Test::More;
use Net::DHCP::Config::Utilities;
use Net::DHCP::Config::Utilities::INI_loader;

BEGIN {
    use_ok( 'Net::DHCP::Config::Utilities::Generator::ISC_DHCPD' ) || print "Bail out!\n";
}

my $dhcp_util=Net::DHCP::Config::Utilities->new;
my $ini_loader=Net::DHCP::Config::Utilities::INI_loader->new($dhcp_util);
$ini_loader->load_dir( 't/ini/' );

my $worked=0;
my $generator;
eval{
	$generator=Net::DHCP::Config::Utilities::Generator::ISC_DHCPD->new({
																		'footer'=>'t/iscdhcpd/footer',
																		'header'=>'t/iscdhcpd/header',
																		'vars'=>{a=>1},
																		'output'=>'t/iscdhcpd/output',
																		});
	$worked=1;
};
ok( $worked eq '1', 'init') or diag('new failed with... '.$@);

$worked=0;
eval{
	$generator->generate( $dhcp_util );
	$worked=1;
};
ok( $worked eq '1', 'generate') or diag('generator failed with... '.$@);

done_testing(3);
