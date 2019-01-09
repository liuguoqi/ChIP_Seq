# ChIP_Seq

description :

Calculate ChIP_Seq median updown 200bp covered by reads .

1, count number is aligned to reference sequence positive start position by reads.

2, count number is aligned to reference sequence negative start position + reads length .

3, output all.tsv , positive.tsv ,negative.tsv three file .

Script  :



Usage:perl Calculate_ChIP_Seq_Peaks200bp_ReadsNumber.pl [options]

         -h            Print help document and Exit
         
         -i*  <str>    Must input Peaks file including 3 columns : chr start end
         
         -b*  <str>    Must input aligned file can handle soap,sam,bam format file  
         
         -o   <str>    Output dir  default current dir ./
         
         -r   <int>    Aligned file whether + or - column number default : 7
         
         -f   <int>    Aligned file reference column number default : 8
         
         -p   <int>    Aligned file reference position column number default : 9
         
         -l   <int>    Reads length default : 83
     
         Example : Calculate_ChIP_Seq_Peaks200bp_ReadsNumber.pl -i CTCF.txt -b DNP_50.soap
