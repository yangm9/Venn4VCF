#!/usr/bin/env perl
use strict;
use FindBin qw($Bin);
use VCF;

my $site_fs=&vcfs2sites(\@ARGV);
chomp(my $Rscript=`which Rscript`);
if(@$site_fs>=2 and @$site_fs<=5){
	my $len=@$site_fs;
	my $paras=join " ",@$site_fs;
	my $samps=$paras;
	$samps=~s/\s+/_/g;
	$samps=~s/\.vcf\.site//g;
	print "$Rscript $Bin/venn$len.R $paras $samps.venn.pdf\n";
	system("$Rscript $Bin/venn$len.R $paras $samps.venn.pdf\n");
    system("rm -f $paras\n");
}else{
	print STDERR "Usage: perl $0 <vcf1> <vcf2> [vcf3] [vcf4] [vcf5]\n";
	print STDERR "It supports at least 2 and at most 5 vcf files.\n";
    exit 1;
}

#Mass generate *.site files from VCF File.
sub vcfs2sites{
	my ($argv)=@_;
	my @site_fs=();
	for my $i(0..$#$argv){
		my $site_f=$argv->[$i].".site";
		&vcf2site($argv->[$i],$site_f);
		push @site_fs, $site_f;
	}
	return \@site_fs;
}

#Extract the chromosome, position, reference and alternative information, and join them with ":" as each line for the output file(*.site). 
sub vcf2site{
	my ($vcf_f,$site_f)=@_;
	my $vcf_o=VCF->new(file=>$vcf_f);
	open OUT, ">$site_f" or die $!;
    $vcf_o->parse_header();
	while(my $x=$vcf_o->next_data_array()){
		print OUT "$$x[0]:$$x[1]:$$x[3]:$$x[4]\n";
	}
	close OUT;
	return 0;
}
__END__
=head1 Usage	
perl $0 <vcf1> <vcf2> ... [vcf5]
#It supports at least 2 and at most 5 vcf files.
=cut
