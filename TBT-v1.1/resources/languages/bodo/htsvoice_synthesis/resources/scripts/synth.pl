#!/usr/bin/perl
# ----------------------------------------------------------------- #
#           The HMM-Based Speech Synthesis System (HTS)             #
#           developed by HTS Working Group                          #
#           http://hts.sp.nitech.ac.jp/                             #
# ----------------------------------------------------------------- #
#                                                                   #
#  Copyright (c) 2001-2011  Nagoya Institute of Technology          #
#                           Department of Computer Science          #
#                                                                   #
#                2001-2008  Tokyo Institute of Technology           #
#                           Interdisciplinary Graduate School of    #
#                           Science and Engineering                 #
#                                                                   #
# All rights reserved.                                              #
#                                                                   #
# Redistribution and use in source and binary forms, with or        #
# without modification, are permitted provided that the following   #
# conditions are met:                                               #
#                                                                   #
# - Redistributions of source code must retain the above copyright  #
#   notice, this list of conditions and the following disclaimer.   #
# - Redistributions in binary form must reproduce the above         #
#   copyright notice, this list of conditions and the following     #
#   disclaimer in the documentation and/or other materials provided #
#   with the distribution.                                          #
# - Neither the name of the HTS working group nor the names of its  #
#   contributors may be used to endorse or promote products derived #
#   from this software without specific prior written permission.   #
#                                                                   #
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND            #
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,       #
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF          #
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE          #
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS #
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,          #
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED   #
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,     #
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON #
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,   #
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY    #
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE           #
# POSSIBILITY OF SUCH DAMAGE.                                       #
# ----------------------------------------------------------------- #
print "pranaw0";
@SET        = ('cmp','dur');
@cmp        = ('mgc','lf0');
@dur        = ('dur');
$ref{'cmp'} = \@cmp;
$ref{'dur'} = \@dur;
%nwin = ('mgc' => '3',      # number of windows
         'lf0' => '3',
         'dur' => '0');


$useGV      = 1;      # turn on GV
$cdgv       = 1;
$voice = "voices";
foreach $type (@cmp) {
   $gvpdf{$type} = "$voice/gv-${type}.pdf";
   $gvtrv{$type} = "$voice/tree-gv-${type}.inf";
}

# Speech Analysis/Synthesis Setting ==============
# speech analysis
$sr = 48000;   # sampling rate (Hz)
$fs = 240; # frame period (point)
$fw = 0.55;   # frequency warping
$gm = 0;      # pole/zero representation weight
$lg = 1;     # use log gain instead of linear gain
$fr = $fs/$sr;      # frame period (sec)

# speech synthesis
$pf = 1.4; # postfiltering factor

# Directories & Commands ===============
# project directories

$ENGINE    = 'hts_engine_API-1.06/bin/hts_engine';

# SoX (to add RIFF header)
$SOX       = '/usr/bin/sox';
$SOXOPTION = '2';

# File locations =========================
# data directory
$datdir = "data";

# data location file
$scp{'gen'} = "$datdir/scp/gen.scp";

# converted model & tree files for hts_engine
print "pranaw1";
foreach $set (@SET) {
   foreach $type ( @{ $ref{$set} } ) {
      $trv{$type} = "$voice/tree-${type}.inf";
      $pdf{$type} = "$voice/${type}.pdf";
   }
}
print "pranaw2";
$type       = 'lpf';
$trv{$type} = "$voice/tree-${type}.inf";
$pdf{$type} = "$voice/${type}.pdf";

# window files for parameter generation
$windir = "${datdir}/win";
foreach $type (@cmp) {
   for ( $d = 1 ; $d <= $nwin{$type} ; $d++ ) {
      $win{$type}[ $d - 1 ] = "${type}.win${d}";
   }
}
print "pranaw3";
$type                 = 'lpf';
$d                    = 1;
$win{$type}[ $d - 1 ] = "${type}.win${d}";


# hts_engine (synthesizing waveforms using hts_engine)

   $dir = "gen/hts_engine";

   # hts_engine command line & options
   # model file & trees
   $hts_engine = "$ENGINE -td $trv{'dur'} -tf $trv{'lf0'} -tm $trv{'mgc'} -tl $trv{'lpf'} -md $pdf{'dur'} -mf $pdf{'lf0'} -mm $pdf{'mgc'} -ml $pdf{'lpf'} ";

print "pranaw4";

   # window coefficients
   $type = 'mgc';
   for ( $d = 1 ; $d <= $nwin{$type} ; $d++ ) {
      $hts_engine .= "-dm $voice/$win{$type}[$d-1] ";
   }
   $type = 'lf0';
   for ( $d = 1 ; $d <= $nwin{$type} ; $d++ ) {
      $hts_engine .= "-df $voice/$win{$type}[$d-1] ";
   }
   $type = 'lpf';
   $d    = 1;
   $hts_engine .= "-dl $voice/$win{$type}[$d-1] ";
print "pranaw5";
   # control parameters (sampling rate, frame shift, frequency warping, etc.)
   $lgopt = "-l" if ($lg);
   $hts_engine .= "-s $sr -p $fs -a $fw -g $gm $lgopt -b " . ( $pf - 1.0 ) . " ";


   # GV pdfs
   if ($useGV) {
      $hts_engine .= "-cm $gvpdf{'mgc'} -cf $gvpdf{'lf0'} ";
      if ( $nosilgv && @slnt > 0 ) {
         $hts_engine .= "-k $voice/gv-switch.inf ";
      }
      if ($cdgv) {
         $hts_engine .= "-em $gvtrv{'mgc'} -ef $gvtrv{'lf0'} ";
      }
      $hts_engine .= "-b 0.0 ";    # turn off postfiltering
   }

   # generate waveform using hts_engine
   open( SCP, $scp{'gen'} ) || die "Cannot open $!";
   while (<SCP>) {
      $lab = $_;
      chomp($lab);
      $base = `basename $lab .lab`;
      chomp($base);

      print "Synthesizing a speech waveform from $lab using hts_engine...";
      shell("$hts_engine -or ${dir}/${base}.raw -ot ${dir}/${base}.trace $lab");
   shell("$SOX -c 1 -s -$SOXOPTION -t raw -r $sr ${dir}/${base}.raw -c 1 -s -$SOXOPTION -t wav -r $sr ${dir}/${base}.wav");
   #2.3shell("$hts_engine -or ${dir}/${base}.raw -ow ${dir}/${base}.wav -ot ${dir}/${base}.trace $lab");
      print "done.\n";
   }
   close(SCP);

sub shell($) {
   my ($command) = @_;
   my ($exit);

   $exit = system($command);

   if ( $exit / 256 != 0 ) {
      die "Error in $command\n";
   }
}
