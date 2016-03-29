#!/bin/bash

# THIS IS A FRAGILE SYSTEM, HANDLE WITH CARE.                                #
# --------------------------------------------------------------------------- #

  MAIN=`echo $1 | cut -d ":" -f 2-`
  MAIN="http://freeze.sh/etherpad/export/_/clipoetics.mdsh/6"
  TMPDIR=. ; TMPID=XYZ ; export $TMPID
  OUTDIR=_
  REFURL="http://freeze.sh/etherpad/export/_/references.bib/868"
  wget --no-check-certificate \
        -O ${TMPID}.bib $REFURL > /dev/null 2>&1
  TMPTEX=$TMPDIR/${TMPID}.tex

  echo "converting $MAIN"

# =========================================================================== #
# CONFIGURATION                                                               #
# --------------------------------------------------------------------------- #
  FUNCTIONSBASIC=lib/sh/201508_basic.functions
   FUNCTIONSPLUS=EDIT/150720_pdf.functions
       FUNCTIONS=$TMPDIR/$TMPID.functions.tmp
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
  CITEOPEN="\cite{" ; CITECLOSE="}"
# --------------------------------------------------------------------------- #
  CITEPOPEN="\citep[" ; CITEPCLOSE="]{"
# =========================================================================== #

# --------------------------------------------------------------------------- #
# ACTION HAPPENS HERE!
# --------------------------------------------------------------------------- #

  mdsh2src $MAIN

# --------------------------------------------------------------------------- #
# WRITE TEX SOURCE
# --------------------------------------------------------------------------- #
  echo "\documentclass[12pt,cleardoubleempty]{scrbook}" >  $TMPTEX
  echo "\usepackage{lib/tex/150720_A5}"                 >> $TMPTEX
  # PDF/X COMPLIANCY
  echo "<?xpacket begin='' id='W5M0MpCehiHzreSzNTczkc9d'?>" \
        > `dirname $TMPTEX`/pdfx-1a.xmp
  cp lib/icc/FOGRA39L.icc `dirname $TMPTEX`
  echo "\begin{document}"                               >> $TMPTEX
  cat   $SRCDUMP                                        >> $TMPTEX
  echo "\bibliographystyle{plain}"                      >> $TMPTEX
  echo "\nobibliography{${TMPID}}"                      >> $TMPTEX
  echo "\cleartofour"                                   >> $TMPTEX
  echo "\end{document}"                                 >> $TMPTEX
# --------------------------------------------------------------------------- #
# CORRECTIONS
# APPEND LINES STARTING WITH \cite
  sed -i -e :a -e '$!N;s/\n\\cite/\\cite/;ta' -e 'P;D' $TMPTEX
# --------------------------------------------------------------------------- #
# MAKE PDF
# --------------------------------------------------------------------------- #
  pdflatex -interaction=nonstopmode \
            $TMPTEX  # > /dev/null
  bibtex ${TMPDIR}/${TMPID}.aux
  pdflatex -interaction=nonstopmode \
            $TMPTEX  # > /dev/null
  pdflatex -interaction=nonstopmode \
            $TMPTEX  # > /dev/null

# --------------------------------------------------------------------------- #
# COMBINE PDF FILES (JACKET,MAIN,LICENSE)
# --------------------------------------------------------------------------- #

  MAIN=${TMPID}.pdf
  JACKET=_/150725_jacket.pdf;
  TMPTEX=${TMPID}final.tex
  LICENSE=${TMPID}license.pdf
  LURL="https://github.com/christop/licenses/raw/master/pdf/CC-BY-NC-SA_3.0.pdf"
  wget --no-check-certificate \
        -O ${LICENSE} $LURL > /dev/null 2>&1

  echo "\documentclass[12pt,cleardoubleempty]{scrbook}" >  $TMPTEX
  echo "\usepackage{lib/tex/150720_A5}"                 >> $TMPTEX
  echo "<?xpacket begin='' id='W5M0MpCehiHzreSzNTczkc9d'?>" \
        > `dirname $TMPTEX`/pdfx-1a.xmp
  cp lib/icc/FOGRA39L.icc `dirname $TMPTEX`
  echo "\begin{document}"                               >> $TMPTEX
  echo "\includepdf[scale=1,pages=1-2]{$JACKET}"        >> $TMPTEX
  echo "\includepdf[scale=1,pages=-]{$MAIN}"            >> $TMPTEX
  echo "\includepdf[scale=.95]{$LICENSE}"               >> $TMPTEX
  echo "\includepdf[scale=1,pages=4]{$JACKET}"          >> $TMPTEX
  echo "\end{document}"                                 >> $TMPTEX
  pdflatex -interaction=nonstopmode \
            $TMPTEX  # > /dev/null
  pdflatex -interaction=nonstopmode \
            $TMPTEX  # > /dev/null

  mv ${TMPID}final.pdf $OUTDIR/`date +%y%m%d`_clipoetics.pdf

# =========================================================================== #
# CLEAN UP
  if [ `ls ${TMPID}.* | wc -l` -gt 0 ]; then rm ${TMPID}* ; fi
  rm $TMPDIR/FOGRA39L.icc $TMPDIR/pdfx-1a.xmp* $MDSH

exit 0;

