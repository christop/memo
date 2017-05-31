#!/bin/bash

# PERMUTE SVG LAYERS                                                          #
# --------------------------------------------------------------------------- #
# copyright (c) 2016 Christoph Haag                                           #
# --------------------------------------------------------------------------- #

# This is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
# 
# The software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License below for more details.
# 
# -> http://www.gnu.org/licenses/gpl.txt

# --------------------------------------------------------------------------- #
# CONFIGURATION 
# --------------------------------------------------------------------------- #
  OUTDIR=../_
  TMPDIR=.
  TMP=$TMPDIR/XXX

# --------------------------------------------------------------------------- #
# VALIDATE (PROVIDED) INPUT 
# --------------------------------------------------------------------------- #
  if [ `echo $* | wc -c` -lt 2 ]; then echo "No arguments provided"; exit 0;
  else if [ `ls \`ls ${1}* 2> /dev/null\` 2> /dev/null  | #
             grep "\.svg$" | wc -l` -lt 1 ];              #
        then echo 'No valid svg!'; exit 0;                #    
      # else echo -e "PROCESSING NOW:\n${1}* \n--------------------";
    fi
  fi

# =========================================================================== #
# DO IT NOW!
# =========================================================================== #
  for SVG in `ls \`ls ${1}*\` | grep "\.svg$"`
   do 
# --------------------------------------------------------------------------- #
# MOVE ALL LAYERS ON SEPARATE LINES IN A TMP FILE
# --------------------------------------------------------------------------- #
  sed ':a;N;$!ba;s/\n//g' $SVG           | # REMOVE ALL LINEBREAKS
  sed 's/<g/\n&/g'                       | # MOVE GROUP TO NEW LINES
  sed '/groupmode="layer"/s/<g/4Fgt7R/g' | # PLACEHOLDER FOR LAYERGROUP OPEN
  sed ':a;N;$!ba;s/\n/ /g'               | # REMOVE ALL LINEBREAKS
  sed 's/4Fgt7R/\n<g/g'                  | # RESTORE LAYERGROUP OPEN + NEWLINE
  sed 's/display:none/display:inline/g'  | # MAKE VISIBLE EVEN WHEN HIDDEN
  grep -v 'label="XX_'                   | # REMOVE EXCLUDED LAYERS
  sed 's/<\/svg>/\n&/g'                  | # CLOSE TAG ON SEPARATE LINE
  sed "s/^[ \t]*//"                      | # REMOVE LEADING BLANKS
  tr -s ' '                              | # REMOVE CONSECUTIVE BLANKS
  tee > ${SVG%%.*}.tmp                     # WRITE TO TEMPORARY FILE

# --------------------------------------------------------------------------- #
# GENERATE CODE FOR FOR-LOOP TO EVALUATE COMBINATIONS
# --------------------------------------------------------------------------- #
  # RESET (IMPORTANT FOR 'FOR'-LOOP)
  LOOPSTART="";VARIABLES="";LOOPCLOSE="";CNT=0

  for BASETYPE in `sed ':a;N;$!ba;s/\n/ /g' ${SVG%%.*}.tmp | #
                   sed 's/<g/\n&/g'                  | # GROUPS ON NEWLINE
                   sed '/^<g/s/>/&\n/g'              | # FIRST ON '>' ON NEWLINE
                   grep ':groupmode="layer"'         | #
                   sed '/^<g/s/scape:label/\nlabel/' | #
                   grep ^label                       | #
                   cut -d "\"" -f 2                  | #
                   cut -d "-" -f 1                   | #
                   sort -u`
   do
       ALLOFTYPE=`sed ':a;N;$!ba;s/\n/ /g' ${SVG%%.*}.tmp  | #
                  sed 's/scape:label/\nlabel/g'            | #
                  grep ^label                              | #
                  cut -d "\"" -f 2                         | #
                  grep $BASETYPE                           | #
                  sort -u`                                   #
       LOOPSTART=${LOOPSTART}"for V$CNT in $ALLOFTYPE; do "
       VARIABLES=${VARIABLES}'$'V${CNT}" "
       LOOPCLOSE=${LOOPCLOSE}"done; "
       CNT=`expr $CNT + 1`
  done

# --------------------------------------------------------------------------- #
# EXECUTE CODE FOR FOR-LOOP TO EVALUATE COMBINATIONS
# --------------------------------------------------------------------------- #
  KOMBILIST=kombinationen.list ; if [ -f $KOMBILIST ]; then rm $KOMBILIST ; fi
  eval ${LOOPSTART}" echo $VARIABLES >> $KOMBILIST ;"${LOOPCLOSE}

# --------------------------------------------------------------------------- #
# WRITE SVG FILES ACCORDING TO POSSIBLE COMBINATIONS
# --------------------------------------------------------------------------- #
  COUNT=1
  SVGHEADER=`head -n 1 ${SVG%%.*}.tmp`

  for KOMBI in `cat $KOMBILIST | sed 's/ /DHSZEJDS/g'`
   do
      KOMBI=`echo $KOMBI | sed 's/DHSZEJDS/ /g'`
      SVGOUT=${TMP}_${COUNT}.svg
      head -n 1 ${SVG%%.*}.tmp                           >  $SVGOUT
      for  LAYERNAME in `echo $KOMBI`
        do grep -n "label=\"$LAYERNAME\"" ${SVG%%.*}.tmp >> ${SVGOUT}.tmp
      done
      cat ${SVGOUT}.tmp | sort -n | cut -d ":" -f 2-     >> $SVGOUT
      echo "</svg>"                                      >> $SVGOUT
      rm ${SVGOUT}.tmp
      inkscape --export-pdf=${SVGOUT%.*}.pdf $SVGOUT
      COUNT=`expr $COUNT + 1`
  done

 #pdftk ${TMP}_*.pdf cat output ${SVG%%.*}.pdf





  REFPDF=170530_dry-Sticker.pdf

# --------------------------------------------------------------------------- #
# LAYOUT PRINTSHEETS
# --------------------------------------------------------------------------- #
  e () { echo $1 >> $OUT ; }
# --------------------------------------------------------------------------- #

# EBL20
# X=8 ; Y=11
# EBL30
# X=5 ; Y=8
# EBL40
  X=4 ; Y=6
# EBL60
# X=3 ; Y=4

  OUT=stickers.tex

  ALL=`expr $X \* $Y`
  PACK=`expr $X \* $Y`
  CNT=$PACK

  if [ -f $OUT ]; then rm $OUT ;fi

  e "\documentclass{scrbook}"
  e "\pagestyle{empty}"
  e "\usepackage{pdfpages}"
  e "\usepackage{geometry}"
  e "\geometry{paperwidth=210mm,paperheight=297mm}"
  e "\begin{document}"

  e "\includepdfmerge"
# EBL20
#  e "[nup=${X}x${Y},scale=.2,noautoscale,"
#  e " delta=3.6 3.6,offset=0 0]"
# EBL30
# e "[nup=${X}x${Y},scale=.3,noautoscale,"
# e " delta=-1.5 -10,offset=0 0]"
# EBL40
  e "[nup=${X}x${Y},scale=.41,noautoscale,"
  e " delta=-7.3 -7.3,offset=0 0]"
# EBL60
# e "[nup=${X}x${Y},scale=.61,noautoscale,"
# e " delta=-12 -2,offset=0 0]"

  REFCNT=1
  while [ $REFCNT -le $ALL ];
   do
       PDF=`ls ${TMP}_*.pdf | shuf -n 1`
       PDFALL=${PDFALL},${PDF}
       REFCNT=`expr $REFCNT + 1`
  done

  PDFALL=`echo $PDFALL | cut -d "," -f 2-`

  e "{"$PDFALL"}"
  e "\end{document}"

  pdflatex --output-directory=$OUTDIR $OUT # > /dev/null



# --------------------------------------------------------------------------- #
# REMOVE TEMP FILES
# --------------------------------------------------------------------------- #
  rm ${SVG%%.*}.tmp $KOMBILIST ${TMP}_*.svg ${TMP}_*.pdf

# =========================================================================== #
  done
# =========================================================================== #


exit 0;


