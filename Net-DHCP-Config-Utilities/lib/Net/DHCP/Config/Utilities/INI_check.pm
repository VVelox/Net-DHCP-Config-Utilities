package Net::DHCP::Config::Utilities::INI_check;

use 5.006;
use strict;
use warnings;
use Config::Tiny;
use File::Find::Rule;
use Net::CIDR;
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


=head2 check

=cut

sub check {
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
		my @subnets_keys = keys( %{ $loaded{$file} } );

		my $file_data = { subnets => {} };

		# check each subnet in the file
		foreach my $current_subnet (@subnets_keys) {
			my $subnet = $current_subnet;

			my $subnet_data = { conflicts => [], };

			# checks if there is a different subnet specified in the key
			if ( defined( $loaded{$file}->{$current_subnet}->{subnet} ) ) {
				$subnet = $loaded{$file}->{$current_subnet}->{subnet};
			}

			# Only proceed if we have a mask
			if ( defined( $loaded{$file}->{$current_subnet}->{mask} ) ) {
				my $mask = $loaded{$file}->{$current_subnet}->{mask};

				# convert the subnet address and mask to a CIDR
				my $cidr;
				eval { $cidr = Net::CIDR::addrandmask2cidr( $subnet, $mask ); };
				if ($@) {

					# If the above errored, then stop processing this subnet error
					$subnet_data->{cidr}
						= '"' . $subnet . '" with a mask for "' . $mask . '" can not be converted to a CIDR... ' . $@;
				}
				else {
					# go through, checking each subnet
					foreach my $current_subnet_other (@subnets_keys) {

						# make sure we don't process the current subnet
						# also make sure the other subnet has a mask
						if (   ( $current_subnet_other ne $current_subnet )
							&& ( defined( $loaded{$file}->{$current_subnet_other}->{mask} ) ) )
						{
							my $subnet_other = $current_subnet_other;
							my $mask_other = $loaded{$file}->{$current_subnet_other}->{mask};

							# checks if there is a different subnet specified in the key
							if ( defined( $loaded{$file}->{$current_subnet_other}->{subnet} ) ) {
								$subnet_other = $loaded{$file}->{$current_subnet_other}->{subnet};
							}

							# create a CIDR for the other subnet and if it can be created, check it
							my $cidr_other;
							eval { $cidr_other = Net::CIDR::addrandmask2cidr( $subnet_other, $mask_other ); };
							if (!$@) {
								
							}
						}
					}
				}
			}
			else {
				$subnet_data->{'mask'} = 'None specified';
			}

			$file_data->{$current_subnet} = $subnet_data;
		}

		$to_return->{$file} = $file_data;
	}

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
