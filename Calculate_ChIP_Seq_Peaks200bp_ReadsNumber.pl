##################################################################
###Author : GuoqiLiu                                             #
###Date   : 2019-01-08                                           #
###Copyright (C) 2018~2019 precisiongenes.com.cn                 #
###Contact: liuguoqi@hmzkjy.cn                                   #
###Suppose: calculate ChIP-seq Peaks 200bp reads number          #
###step :                                                        #
###1. calculate Peaks median 200bp was aligned reads number      #
###2. centralized reference position  -100~100bp                 #
###Platform :                                                    #
############Centos7 & Windows10 ,Perl v5.16.3#####################
##################################################################
#log:
#Updated 2019-01-09 write all && positive && negative  file tree file and -o file modify dir
use POSIX;
use strict ;
use warnings ;
use Getopt::Long;
use Cwd;
my $VERSION = "V1.1";
my $current_dir = getcwd() ;
my %opts;
my $help;
GetOptions (\%opts,"i=s","b=s","o=s","r=i","f=i","p=i","l=i","h!"=> \$help) ;
my $usage = <<"USAGE";
################################################################################################################
#         Usage:perl $0 [options] 
#         -h            Print help document and Exit 
#         -i*  <str>    Must input Peaks file including 3 columns : chr start end
#         -b*  <str>    Must input aligned file can handle soap,sam,bam format file  
#         -o   <str>    Output dir  default current dir ./
#         -r   <int>    Aligned file whether + or - column number default : 7
#         -f   <int>    Aligned file reference column number default : 8
#         -p   <int>    Aligned file reference position column number default : 9
#         -l   <int>    Reads length default : 83
#     
#         Example : $0 -i CTCF.txt -b DNP_50.soap
################################################################################################################
#         Program : $0
#         Version : $VERSION
#         Contact : liuguoqi\@hmzkjy.cn
################################################################################################################
USAGE
die $usage if ( !$opts{i});
die $usage if ( !$opts{b});
if ($help){&usage();exit;}
#set default argruments#
$opts{o}=defined $opts{o}?$opts{o}:"./"; ###output dir ###
$opts{r}=defined $opts{r}?$opts{r}:7; ### ###
$opts{f}=defined $opts{f}?$opts{f}:8; ##### 
$opts{p}=defined $opts{p}?$opts{p}:9; #### 
$opts{l}=defined $opts{l}?$opts{l}:83; #### 
###########################time
sub GetTime {
    my $current_time=`date "+%Y-%m-%d %H:%M:%S"`;
    return $current_time;
    
}
my $time = &GetTime();
chomp($time);
#print "\@",$time," This is a testing\n";
########################mid of Peaks
sub mid{
    my @list = sort{$a<=>$b} @_;
    my $count = @list;
    if( $count == 0 )
      {
          return undef;
      }   
    if(($count%2)==1)
      {
          return $list[int(($count-1)/2)];
      }
    elsif(($count%2)==0)
      {
         return ($list[int(($count-1)/2)]+$list[int(($count)/2)])/2;
      }
}
###build Peaks  name and value 
#chr1    865876  865940
my @peaksValue;
my %Peaks_Name = () ;
my %Peaks_Value = () ;
#updated
my %Peaks_Value1 = () ;
my %Peaks_Value2 = () ;
#

my %peaks2position;
open PEAKS,$opts{i} ;
while (<PEAKS>) {
     chomp;
     my @peaks = split/\s+/,$_ ;
     my $mid_value = mid($peaks[1]..$peaks[2]) ;
     $mid_value = int($mid_value) ;
     my @real = ($mid_value-100..$mid_value,$mid_value+1..$mid_value+100) ;
     my @abs = (-100..100) ;
     push @peaksValue,$peaks[0]."\t".$peaks[1]."\t".$peaks[2];
     #print "@abs","\n" ;
     for(my $i=0;$i<=$#real;$i++) {
          $peaks2position{$peaks[0].$real[$i]} = $peaks[0].$abs[$i] ;
          $Peaks_Value{$peaks[0].$real[$i]} = 0 ;
          #updated
          $Peaks_Value1{$peaks[0].$real[$i]} = 0 ;
          $Peaks_Value2{$peaks[0].$real[$i]} = 0 ;
          #
          $Peaks_Name{$peaks[0]."\t".$peaks[1]."\t".$peaks[2]}{$peaks[0].$abs[$i]} =  $peaks[0].$real[$i];
	}
          
     #print join("\t",($mid_value-100..$mid_value)),"\t",join("\t",($mid_value+1..$mid_value+100)),"\n";
     #print join("\t",(-100..100)),"\n";
}
close PEAKS;
#foreach my $ky (keys %peaks2position) {
#    print $ky,"==>>>",$peaks2position{$ky},"\n" ;
#} 
if ($opts{b} =~ m/\.bam$/) {
    open SAM,"samtools view $opts{b} | " ;
    #print "ok\n";
}
else {
	open SAM,$opts{b} ;
}

while(<SAM>) {
    chomp;
   # print $_,"\n";
    my @sam = split/\t/,$_; 
    if ($sam[$opts{r}-1] eq "+" && exists $Peaks_Value{$sam[$opts{f}-1].$sam[$opts{p}-1]}) {
        $Peaks_Value{$sam[$opts{f}-1].$sam[$opts{p}-1]} ++ ;
        #updated
        $Peaks_Value1{$sam[$opts{f}-1].$sam[$opts{p}-1]} ++ ;
     }
    elsif ($sam[$opts{r}-1] eq "-" && exists $Peaks_Value{$sam[$opts{f}-1].($sam[$opts{p}-1]+$opts{l})}) {
        $Peaks_Value{$sam[$opts{f}-1].($sam[$opts{p}-1]+$opts{l})} ++ ;
        #updated
        $Peaks_Value2{$sam[$opts{f}-1].($sam[$opts{p}-1]+$opts{l})} ++ ;
     }
}
close SAM ;

#foreach my $ky (keys %Peaks_Value) {
#    print $ky,"==>>>",$Peaks_Value{$ky},"\n" ;
#}

open OUT ,">",$opts{o}."/all.tsv" ;
#updated
open OUT1 ,">",$opts{o}."/positive.tsv" ;
open OUT2 ,">",$opts{o}."/negative.tsv" ;
#
print OUT "chr\tstart\tend\t",join("\t",(-100..100)),"\n";
print OUT1 "chr\tstart\tend\t",join("\t",(-100..100)),"\n";
print OUT2 "chr\tstart\tend\t",join("\t",(-100..100)),"\n";
foreach my $k1 (@peaksValue) {
       print OUT $k1;
       print OUT1 $k1;
       print OUT2 $k1;
       my @chr = split/\t/,$k1;
       foreach my $k2 (-100..100) {
               print OUT "\t",$Peaks_Value{${$Peaks_Name{$k1}}{$chr[0].$k2}};
               print OUT1 "\t",$Peaks_Value1{${$Peaks_Name{$k1}}{$chr[0].$k2}};
               print OUT2 "\t",$Peaks_Value2{${$Peaks_Name{$k1}}{$chr[0].$k2}};
       #print OUT "\n";
       }
       print OUT "\n";
       print OUT1 "\n";
       print OUT2 "\n";
}
close OUT ;
close OUT1 ;
close OUT2 ;
