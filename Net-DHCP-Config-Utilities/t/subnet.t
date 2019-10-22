#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 6;

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

$worked=0;
eval{
	my $base=$subnet->base_get;
	if ( $base ne $options->{base} ){
		die( '"'.$base.'" was returned for the base, but "'.$options->{base}.'" was expcted');
	}
	$worked=1;
};
ok( $worked eq '1', 'base_get') or diag('base_get failed with... '.$@);

$worked=0;
eval{
	my $desc=$subnet->desc_get;
	if ( $desc ne $options->{desc} ){
		die( '"'.$desc.'" was returned for the base, but "'.$options->{desc}.'" was expcted');
	}
	$worked=1;
};
ok( $worked eq '1', 'desc_get') or diag('desc_get failed with... '.$@);

$worked=0;
eval{
	my $mask=$subnet->mask_get;
	if ( $mask ne $options->{mask} ){
		die( '"'.$mask.'" was returned for the mask, but "'.$options->{mask}.'" was expcted');
	}
	$worked=1;
};
ok( $worked eq '1', 'mask_get') or diag('mask_get failed with... '.$@);

$worked=0;
eval{
	my $option=$subnet->option_get('dns');
	if ( $option ne $options->{dns} ){
		die( '"'.$option.'" was returned for the option dns, but "'.$options->{dns}.'" was expcted');
	}
	$worked=1;
};
ok( $worked eq '1', 'option_get') or diag('option_get failed with... '.$@);
