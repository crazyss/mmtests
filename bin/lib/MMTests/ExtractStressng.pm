# ExtractStressng.pm
package MMTests::ExtractStressng;
use MMTests::SummariseMultiops;
use MMTests::Stat;
our @ISA = qw(MMTests::SummariseMultiops);
use strict;

sub initialise() {
	my ($self, $reportDir, $testName) = @_;
	$self->{_ModuleName} = "ExtractStressng";
	$self->{_DataType}   = DataTypes::DATA_OPS_PER_SECOND;
	$self->{_PlotType}   = "operation-candlesticks";

	$self->SUPER::initialise($reportDir, $testName);
}

sub extractReport() {
	my ($self, $reportDir, $reportName, $profile) = @_;

	my @files = <$reportDir/$profile/stressng-*-1.log>;
	my @clients;
	foreach my $file (@files) {
		my @split = split /-/, $file;
		push @clients, $split[-2];
	}
	@clients = sort { $a <=> $b } @clients;

	foreach my $client (@clients) {
		foreach my $file (<$reportDir/$profile/stressng-$client-*>) {
			my @split = split /-/, $file;
			$split[-1] =~ s/.log//;
			my $iteration = $split[-1];

			open(INPUT, $file) || die("Failed to open $file\n");
			my $reading = 0;
			while (!eof(INPUT)) {
				my $line = <INPUT>;

				if ($line =~ /\(secs\)/) {
					$reading = 1;
					next;
				}
				next if !$reading;

				$line =~ s/.*\] //;
				my @elements = split /\s+/, $line;

				my $testname = $elements[0];
				my $ops_sec = $elements[5];
				$self->addData("$testname-$client", $iteration, $ops_sec);
			}
			close(INPUT);
		}
	}
}

1;
