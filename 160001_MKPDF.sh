#!/bin/bash

# THIS IS A FRAGILE SYSTEM, HANDLE WITH CARE.                                #
# --------------------------------------------------------------------------- #

  MAIN=EDIT/151019_strlov.mdsh
 #MAIN=EDIT/160126_doodle.mdsh

  TMPDIR=. ;  TMPID=$TMPDIR/TMP`date +%Y%m%H``echo $RANDOM | cut -c 1-4`
  SRCDUMP=${TMPID}.maindump
  OUTDIR=FREEZE
  SELECTLINES="tee"
  TMPTEX=${TMPID}.tex

# =========================================================================== #
# CONFIGURATION                                                               #
# --------------------------------------------------------------------------- #
  source lib/sh/prepress.functions

# INCLUDE/COMBINE FUNCTIONS
# --------------------------------------------------------------------------- #
  FUNCTIONSBASIC="lib/sh/201511_basic.functions"
   FUNCTIONSPLUS="lib/sh/160127_pdf.functions"
       FUNCTIONS=$TMPID.functions
  cat $FUNCTIONSBASIC $FUNCTIONSPLUS > $FUNCTIONS
  source $FUNCTIONS

# --------------------------------------------------------------------------- #
# GET BIBREF FILE
# --------------------------------------------------------------------------- #
  REFURL="http://freeze.sh/etherpad/export/_/references.bib"
  # wget --no-check-certificate \
  #      -O ${TMPID}.bib $REFURL > /dev/null 2>&1
  getFile $REFURL ${TMPID}.bib

# --------------------------------------------------------------------------- #
# DEFINITIONS SPECIFIC TO OUTPUT
# --------------------------------------------------------------------------- #
  PANDOCACTION="pandoc --ascii -V links-as-notes -r markdown -w latex"
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

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# --------------------------------------------------------------------------- #
# ACTION STARTS HERE!
# --------------------------------------------------------------------------- #
  mdsh2src $MAIN



  if [ `ls $SRCDUMP 2>/dev/null | wc -l` -gt 0 ]; then
# --------------------------------------------------------------------------- #
# WRITE TEX SOURCE
# --------------------------------------------------------------------------- #
  echo "\documentclass[8pt,cleardoubleempty]{scrbook}"  >  $TMPTEX
  echo "\usepackage{lib/tex/151007_A5}"                 >> $TMPTEX
  echo "\bibliography{${TMPID}.bib}"                    >> $TMPTEX
  echo "\begin{document}"                               >> $TMPTEX
  cat   $SRCDUMP                                        >> $TMPTEX
  echo "\end{document}"                                 >> $TMPTEX
 
# --------------------------------------------------------------------------- #
# MODIFY SRC BEFORE COMPILING
# --------------------------------------------------------------------------- #
  sed -i "s/--\\\textgreater{}/\\\ding{222}/g" $TMPTEX


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
  rm ${TMPID}*.toc
  rm ${TMPID}*.licenses
  rm ${TMPID}*.qrurls
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


