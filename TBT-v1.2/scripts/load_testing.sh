#! bin/bash

###########################################################################
##                                                                       ##
##                Centre for Development of Advanced Computing           ##
##                               Mumbai                                  ##
##                         Copyright (c) 2017                            ##
##                        All Rights Reserved.                           ##
##                                                                       ##
##  Permission is hereby granted, free of charge, to use and distribute  ##
##  this software and its documentation without restriction, including   ##
##  without limitation the rights to use, copy, modify, merge, publish,  ##
##  distribute, sublicense, and/or sell copies of this work, and to      ##
##  permit persons to whom this work is furnished to do so, subject to   ##
##  the following conditions:                                            ##
##   1. The code must retain the above copyright notice, this list of    ##
##      conditions and the following disclaimer.                         ##
##   2. Any modifications must be clearly marked as such.                ##
##   3. Original authors' names are not deleted.                         ##
##   4. The authors' names are not used to endorse or promote products   ##
##      derived from this software without specific prior written        ##
##      permission.                                                      ##
##                                                                       ##
##                                                                       ##
###########################################################################
##                                                                       ##
##                     TTS Building Toolkit                              ##
##                                                                       ##
##            Designed and Developed by Atish and Rachana                ##
##          		Date:  April 2017                                ##
##                                                                       ## 
###########################################################################

LNG=$1
GENDER=$2

tar -xvzf ../resources/languages/$LNG/htsvoice_synthesis.tar.gz -C ../
cd output/
mv cmu_us_arctic_slt.htsvoice indic_$LNG\_$GENDER.htsvoice      ##changing the name of htsvoice file in output dir.
cd ..
rm -rf ../htsvoice_synthesis/voices/*.htsvoice
cp ../output/indic_$LNG\_$GENDER.htsvoice ../htsvoice_synthesis/voices

cp $FESTDIR/src/main/festival ../htsvoice_synthesis/resources/bin/

sudo locate hts_engine_API-1.10 > hts_engine_list
hts_engine=$(head -1 hts_engine_list)
cp $hts_engine/bin/hts_engine ../htsvoice_synthesis/resources/bin/

cd ../htsvoice_synthesis/
perl synth_text.pl "छत्रपती शिवाजी महाराजांच्या शौर्याची, कर्तृत्वाची, पराक्रमाची खूप महान महती आहे."

echo "Done with HTS-VOCE tesing pre-requisits"
