#!/bin/bash

# THIS IS A FRAGILE SYSTEM, HANDLE WITH CARE.                                #
# --------------------------------------------------------------------------- #

 #MAIN=JUNK/spread.mdsh
 #MAIN=http://freeze.sh/etherpad/export/_/dev.mdsh
 #MAIN=JUNK/dev3.mdsh
  MAIN=JUNK/recursion.mdsh

  TMPDIR=. ;  TMPID=$TMPDIR/TMP`date +%Y%m%H``echo $RANDOM | cut -c 1-4`
  SRCDUMP=${TMPID}.maindump
  OUTDIR=FREEZE
  SELECTLINES="tee"
  TMPTEX=${TMPID}.tex

 #DUMPUNPROCESSED=mdshmaster.dump

 #echo "converting $MAIN"

# =========================================================================== #
# CONFIGURATION                                                               #
# --------------------------------------------------------------------------- #
  FUNCTIONSBASIC=EDIT/sh/000003_basic.functions
   FUNCTIONSPLUS=EDIT/sh/150914_pdf.functions
       FUNCTIONS=$TMPID.functions
  cat $FUNCTIONSBASIC $FUNCTIONSPLUS > $FUNCTIONS
  source $FUNCTIONS

# --------------------------------------------------------------------------- #
  PANDOCACTION="pandoc --ascii -r markdown -w latex"
# --------------------------------------------------------------------------- #
# FOOTNOTES
# \footnote{the end is near, the text is here}
# --------------------------------------------------------------------------- #
  FOOTNOTEOPEN="\footnote{" ; FOOTNOTECLOSE="}"
# CITATIONS
# \cite{phillips:2004:vectoraesthetic}
# --------------------------------------------------------------------------- #
  CITEOPEN="\cite{"   ; CITECLOSE="}"
# --------------------------------------------------------------------------- #
  CITEPOPEN="\citep[" ; CITEPCLOSE="]{"
# =========================================================================== #






# --------------------------------------------------------------------------- #
# ACTION HAPPENS HERE!
# --------------------------------------------------------------------------- #

  mdsh2src $MAIN








  if [ `ls $SRCDUMP 2>/dev/null | wc -l` -gt 0 ]; then

  cp $SRCDUMP debug.mdsh

  rm $SRCDUMP

  else 

  echo "not existing"

  fi


# =========================================================================== #
# CLEAN UP

  rm ${TMPID}*.[1-9]*.*
  rm ${TMPID}*.functions
  rm ${TMPID}*.included
  rm ${TMPID}.fid
 #rm ${TMPID}*.pdf



exit 0;
















# --------------------------------------------------------------------------- #
# WRITE TEX SOURCE
# --------------------------------------------------------------------------- #
  echo "\documentclass[12pt,cleardoubleempty]{scrbook}" >  $TMPTEX
  echo "\usepackage{150731_A5}"                         >> $TMPTEX
  echo "\bibliography{${TMPID}.bib}"                    >> $TMPTEX
  # PDF/X COMPLIANCY
  echo "<?xpacket begin='' id='W5M0MpCehiHzreSzNTczkc9d'?>" \
        > `dirname $TMPTEX`/pdfx-1a.xmp
  cp ../lib/icc/FOGRA39L.icc `dirname $TMPTEX`
  echo "\begin{document}"                               >> $TMPTEX
  cat   $SRCDUMP                                        >> $TMPTEX
  echo "\cleartofour"                                   >> $TMPTEX
  echo "\end{document}"                                 >> $TMPTEX

# --------------------------------------------------------------------------- #
# CORRECTIONS
# APPEND LINES STARTING WITH \cite
  sed -i -e :a -e '$!N;s/\n\\cite/\\cite/;ta' -e 'P;D' $TMPTEX
  sed -i "s/{quote}/{quotation}/g" $TMPTEX
# --------------------------------------------------------------------------- #
# MAKE PDF
# --------------------------------------------------------------------------- #
  pdflatex -interaction=nonstopmode \
            $TMPTEX  # > /dev/null
  biber `echo ${TMPTEX} | rev | cut -d "." -f 2- | rev`
  pdflatex -interaction=nonstopmode \
            $TMPTEX  # > /dev/null
  pdflatex -interaction=nonstopmode \
            $TMPTEX  # > /dev/null

# --------------------------------------------------------------------------- #
# COMBINE PDF FILES (JACKET,MAIN,LICENSE)
# --------------------------------------------------------------------------- #

  MAIN=${TMPID}.pdf
  JACKET=../FREEZE/150725_jacket.pdf;
  TMPTEX=${TMPID}final.tex
# LICENSE=${TMPID}license.pdf
# LURL="https://github.com/christop/licenses/raw/master/pdf/CC-BY-NC-SA_3.0.pdf"
# wget --no-check-certificate \
#       -O ${LICENSE} $LURL > /dev/null 2>&1

  echo "\documentclass[12pt,cleardoubleempty]{scrbook}" >  $TMPTEX
  echo "\usepackage{150731_A5}"                         >> $TMPTEX
  echo "<?xpacket begin='' id='W5M0MpCehiHzreSzNTczkc9d'?>" \
        > `dirname $TMPTEX`/pdfx-1a.xmp
  cp ../lib/icc/FOGRA39L.icc `dirname $TMPTEX`
  echo "\begin{document}"                               >> $TMPTEX
  echo "\includepdf[scale=1,pages=1-2]{$JACKET}"        >> $TMPTEX
  echo "\includepdf[scale=1,pages=-]{$MAIN}"            >> $TMPTEX
# echo "\includepdf[scale=.95]{$LICENSE}"               >> $TMPTEX
  echo "\includepdf[scale=1,pages=4]{$JACKET}"          >> $TMPTEX
  echo "\end{document}"                                 >> $TMPTEX
  pdflatex -interaction=nonstopmode \
            $TMPTEX  # > /dev/null
  pdflatex -interaction=nonstopmode \
            $TMPTEX  # > /dev/null

  mv ${TMPID}final.pdf ../FREEZE/debug.pdf



exit 0;

