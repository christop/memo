#!/bin/bash

# THIS IS A FRAGILE SYSTEM, HANDLE WITH CARE.                                #
# --------------------------------------------------------------------------- #

  MAIN=JUNK/lokal.mdsh
 #MAIN=http://freeze.sh/etherpad/export/_/memo.mdsh

  TMPDIR=. ;  TMPID=$TMPDIR/TMP`date +%Y%m%H``echo $RANDOM | cut -c 1-4`
  SRCDUMP=${TMPID}.maindump
  OUTDIR=FREEZE
  SELECTLINES="tee"
  TMPTEX=${TMPID}.tex

# =========================================================================== #
# CONFIGURATION                                                               #
# --------------------------------------------------------------------------- #
# INCLUDE/COMBINE FUNCTIONS
# --------------------------------------------------------------------------- #
  FUNCTIONSBASIC=EDIT/sh/000003_basic.functions
   FUNCTIONSPLUS=EDIT/sh/150914_pdf.functions
       FUNCTIONS=$TMPID.functions
  cat $FUNCTIONSBASIC $FUNCTIONSPLUS > $FUNCTIONS
  source $FUNCTIONS

# GET BIBREF FILE
# --------------------------------------------------------------------------- #
  REFURL="http://freeze.sh/etherpad/export/_/references.bib"
  # wget --no-check-certificate \
  #      -O ${TMPID}.bib $REFURL > /dev/null 2>&1
  getFile $REFURL ${TMPID}.bib



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
# --------------------------------------------------------------------------- #
# WRITE TEX SOURCE
# --------------------------------------------------------------------------- #
  echo "\documentclass[8pt,cleardoubleempty]{scrbook}"  >  $TMPTEX
  echo "\usepackage{EDIT/tex/151007_A5}"                >> $TMPTEX
 #echo "\usepackage{EDIT/OLDEDITROOT/150731_A5}"        >> $TMPTEX
  echo "\bibliography{${TMPID}.bib}"                    >> $TMPTEX
  echo "\begin{document}"                               >> $TMPTEX
  cat   $SRCDUMP                                        >> $TMPTEX
  echo "\end{document}"                                 >> $TMPTEX


# --------------------------------------------------------------------------- #
# MODIFY SRC BEFORE COMPILING
# --------------------------------------------------------------------------- #
 #ORDINALS:\newcommand{\ts}{\textsuperscript}
 #echo "14th 345chd 3rd rd 1st 2nd ddnd" | #
 #sed -e 's/\(\([0-9]\)\+\)\(st\|nd\|rd\|th\)\+/\1\\ts{\3}/g'

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

# D E B U G D E B U G D E B U G D E B U G D E B G D E B U D E B U G D E B U G #
  cp ${TMPID}.pdf debug.pdf
  cp $TMPTEX debug.tex

  else 

  echo "not existing"

  fi


# =========================================================================== #
# CLEAN UP

# SHOULD HAVE rmif FUNCTION
  rm $SRCDUMP
  rm ${TMPID}*.[1-9]*.*
  rm ${TMPID}*.functions
  rm ${TMPID}*.included
  rm ${TMPID}.tex
  rm ${TMPID}.aux
 #rm ${TMPID}.pdf
  rm ${TMPID}.log
  rm ${TMPID}*.pdf
  rm ${TMPID}*.bib
  rm ${TMPID}*.wget
  rm ${TMPID}*.info
  rm ${TMPID}SRC*.*
# BIBER
  rm ${TMPID}*.bbl
  rm ${TMPID}*.bcf
  rm ${TMPID}*.blg
 #rm ${TMPID}*.out
  rm ${TMPID}*.run.xml
  

  if [ `ls ${TMPID}.fid 2>/dev/null | wc -l` -gt 0 ];then
  rm ${TMPID}.fid
  fi

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

