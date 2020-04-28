package Net::DHCP::Config::Utilities::INI_check;

use 5.006;
use strict;
use warnings;
use Config::Tiny;
use File::Find::Rule;
use Net::CIDR;
use Net::CIDR::Overlap;
#use Net::DHCP::Config::Utilities::Options;

=head1 NAME

Net::DHCP::Config::Utilities::INI_check - Loads subnet configurations from a INI file and checks it for overlaps.

=head1 VERSION

Version 0.0.1

=cut

our $VERSION = '0.0.1';

=head1 SYNOPSIS


=head1 METHODS

=head2 new

This initiates the object.

=cut

sub new {
	my $dir  = $_[1];
	my $name = $_[2];

	if ( !defined($dir) ) {
		die 'No directory defined';
	}
	elsif ( !-d $dir ) {
		die '"' . $dir . '" is not a dir';
	}

	if ( !defined($name) ) {
		$name = '*.dhcp.ini';
	}

	my $self = {
		dir  => $dir,
		name => $name,
	};
	bless $self;

	return $self;
}


=head2 cidr_check

=cut

sub cidr_check {
	my $self = $_[0];

	# the files to find
	my @files = File::Find::Rule->file()
	->name( $self->{name} )
	->in( $self->{dir} );

	# the data to return
	my $to_return = {};

	# make ainitial pass through, loading them all
	my %loaded;
	foreach my $file (@files) {
		my $ini;
		eval { $ini = Config::Tiny->new($file); };
		if ( $@ || ( !defined($ini) ) ) {

			# put the error description together
			my $error;
			if ( !defiend($ini) ) {
				$error = 'Did not die but returned undef.';
			}
			else {
				$error = $@;
			}
			$to_return->{$file} = { 'load' => 'failed to load... ' . $error };
		}
		$loaded{$file} = $ini;
	}

	# go through and check each file
	foreach my $file ( keys(%loaded) ) {
		
	}

}

=head2 cidr_in_file

This goes through the INI file and checks the subnets there for any
overlap with the specified CIDR.

Two arguments are required. The first is the CIDR to check for and the
second is the INI DHCP file to check for overlaps in.

Any subnets with bad base/mask that don't convert properly to a CIDR
are skipped.

The returned value is a array reference of any found conflicts.

    my $overlaps=$ini_check->cidr_in_file( $cidr, $file );
    if ( defined( $overlaps->[0] ) ){
        print "Overlap(s) found\n";
    }

=cut

sub cidr_in_file {
	my $self = $_[0];
	my $cidr = $_[1];
	my $file = $_[2];
	my $ignore = $_[3];

	# make sure they are both defined before going any further
	if (   ( !defined($cidr) )
		|| ( !defined($file) ) )
	{
		die 'Either CIDR or file undefined';
	}

	# make sure the CIDR has a /, the next test will pass regardless
	if ( $cidr !~ /\// ) {
		die 'The value passed for the CIDR does not contain a /';
	}

	# make sure the CIDR is valid
	my $cidr_test;
	eval { $cidr_test = Net::CIDR::cidrvalidate($cidr); };
	if ( $@ || ( !defined($cidr_test) ) ) {
		die '"' . $cidr . '" is not a valid CIDR';
	}

	# make sure we can read the INI file
	my $ini;
	eval { $ini = Config::Tiny->new($file); };
	if ( $@ || ( !defined($ini) ) ) {
		my $extra_dead='';
		if ($@) {
			$extra_dead='... '.$@;
		}
		die 'Failed to load the INI file';
	}

	# build a list of the sections with masks
	my @ini_keys_found = keys( %{$ini} );
	my %subnets;
	foreach my $current_key (@ini_keys_found) {
		my $ref_test = $ini->{$current_key};

		# if it is a hash and has a subnet mask, add it to the list
		if ( ( ref($ref_test) eq 'HASH' )
			&& defined( $ini->{$current_key}{mask} ) )
		{
			$subnets{$current_key} = 1;
		}
	}

	# Config::Tiny uses _ for variables not in a section
	# This really should never be true as there is no reason for this section
	# to contain the mask variable.
	if ( defined( $subnets{_} ) ) {
		delete( $subnets{_} );
	}

	# If a ignore is specified, remove it, if it is defined
	if (   defined($ignore)
		&& defined( $subnets{$ignore} ) )
	{
		delete( $subnets{$ignore} );
	}


	# holds the overlaps
	my @overlaps;

	# go through and test each CIDR
	foreach my $subnet_current ( keys(%subnets) ) {
		my $subnet = $subnet_current;
		my $mask   = $ini->{$subnet_current}{mask};

		if ( defined( $ini->{$subnet_current}{base} ) ) {
			$subnet = $ini->{$subnet_current}{base};
		}

		my $cidr_other;
		eval { $cidr_other = Net::CIDR::addrandmask2cidr( $subnet, $mask ); };
		if ( !$@ ) {
			my $nco = Net::CIDR::Overlap->new;
			$nco->add($cidr);

			eval { $nco->add($cidr_other); };
			if ($@) {
				push( @overlaps, $subnet_current );
			}
		}
	}

	return \@overlaps;
}

=head1 AUTHOR

Zane C. Bowers-Hadley, C<< <vvelox at vvelox.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-dhcp-config-utilities at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-DHCP-Config-Utilities>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::DHCP::Config::Utilities


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-DHCP-Config-Utilities>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-DHCP-Config-Utilities>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Net-DHCP-Config-Utilities>

=item * Search CPAN

L<https://metacpan.org/release/Net-DHCP-Config-Utilities>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2020 by Zane C. Bowers-Hadley.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)


=cut

1;    # End of Net::DHCP::Config::Utilities
