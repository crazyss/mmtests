# ExtractHpcc.pm
package MMTests::ExtractHpcc;
use MMTests::SummariseMultiops;
our @ISA = qw(MMTests::SummariseMultiops);
use strict;

sub new() {
	my $class = shift;
	my $self = {
		_ModuleName  => "ExtractHpcc",
		_DataType    => DataTypes::DATA_OPS_PER_SECOND,
	};
	bless $self, $class;
	return $self;
}

sub extractReport() {
	my ($self, $reportDir, $reportName, $profile) = @_;
	my $iteration = 0;
	my @metric_list = ("HPL_Tflops", "PTRANS_GBs", "MPIRandomAccess_GUPs", "MPIFFT_Gflops", "StarSTREAM_Triad", "StarDGEMM_Gflops", "RandomlyOrderedRingBandwidth_GBytes");

	foreach my $file (<$reportDir/$profile/hpccoutf-*.txt>) {
		$iteration++;

		open (INPUT, $file) || die("Failed to open $file");
		while (!eof(INPUT)) {
			my $line = <INPUT>;

			foreach my $metric (@metric_list) {
				if ($line =~ /^$metric=(.*)/) {
					$self->addData("$metric", $iteration, $1);
				}
			}
		}
		close (INPUT);
	}

	$self->{_Operations} = \@metric_list;
}

1;
