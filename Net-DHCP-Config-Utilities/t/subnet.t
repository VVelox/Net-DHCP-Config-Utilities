#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 2;

BEGIN {
    use_ok( 'Net::DHCP::Config::Utilities::Subnet' ) || print "Bail out!\n";
}

my $options={
			 base=>'10.0.0.0',
			 mask=>'255.255.255.0',
			 dns=>'10.0.0.1 , 10.0.10.1',
			 desc=>'a example subnet',
			 };

my $worked=0;
my $subnet;
eval{
	$subnet=Net::DHCP::Config::Utilities::Subnet->new($options);
	$worked=1;
};
ok( $worked eq '1', 'init') or diag('new failed with... '.$@);

if( $ENV{'perl_dev_test'} ){
	use Data::Dumper;
	diag( "object dump...\n".Dumper( $subnet ) );
}

