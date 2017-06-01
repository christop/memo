#!/bin/bash

# PERMUTE SVG LAYERS AND ARRANGE ON A4 SHEET (TO PRINT)                       #
# --------------------------------------------------------------------------- #
# copyright (c) 2017 Christoph Haag                                           #
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
  LAYOUT=EBL30NEU
  TMPDIR=.;TMPID=$TMPDIR/XXX
# --------------------------------------------------------------------------- #
# VALIDATE (PROVIDED) INPUT 
# --------------------------------------------------------------------------- #
  if [ `echo $* | wc -c` -lt 2 ]; then echo "No arguments provided"; exit 0;
  else if [ `ls \`ls ${1}* 2> /dev/null\` 2> /dev/null  | #
             grep "\.svg$" | wc -l` -lt 1 ];              #
        then echo 'No valid svg!'; exit 0;                #    
  fi;fi
# =========================================================================== #
# DO IT NOW!
# =========================================================================== #
  for SVG in `ls \`ls ${1}*\` | grep "\.svg$"`
   do 
# --------------------------------------------------------------------------- #
# MOVE ALL LAYERS ON SEPARATE LINES IN A TMP FILE (PROTECT SPACES/BREAKS)
# --------------------------------------------------------------------------- #
  BFOO=NL`echo ${RANDOM} | cut -c 1`F00;SFOO=SP`echo ${RANDOM} | cut -c 1`F0O
  sed ":a;N;\$!ba;s/\n/$BFOO/g" $SVG     | # REMOVE ALL LINEBREAKS (BUT SAVE)
  sed "s/ /$SFOO/g"                      | # REMOVE ALL SPACE (BUT SAVE)
  sed 's/<g/\n&/g'                       | # MOVE GROUP TO NEW LINES
  sed '/groupmode="layer"/s/<g/4Fgt7R/g' | # PLACEHOLDER FOR LAYERGROUP OPEN
  sed ':a;N;$!ba;s/\n//g'                | # REMOVE ALL LINEBREAKS
  sed 's/4Fgt7R/\n<g/g'                  | # RESTORE LAYERGROUP OPEN + NEWLINE
  sed 's/<\/svg>/\n&/g'                  | # CLOSE TAG ON SEPARATE LINE
  sed 's/display:none/display:inline/g'  | # MAKE VISIBLE EVEN WHEN HIDDEN
  grep -v 'label="XX_'                   | # REMOVE EXCLUDED LAYERS
  tee > ${SVG%%.*}.tmp
# --------------------------------------------------------------------------- #
# GENERATE CODE FOR FOR-LOOP TO EVALUATE COMBINATIONS
# --------------------------------------------------------------------------- #
  # RESET (IMPORTANT FOR 'FOR'-LOOP)
  LOOPSTART="";VARIABLES="";LOOPCLOSE="";CNT=0

  for BASETYPE in `sed 's/<g/\n&/g' ${SVG%%.*}.tmp   | # GROUPS ON NEWLINE
                   sed '/^<g/s/>/&\n/g'              | # FIRST ON '>' ON NEWLINE
                   grep ':groupmode="layer"'         | # SELECT LAYER GROUPS
                   sed '/^<g/s/scape:label/\nlabel/' | # PUT LABELS ON NEWLINE
                   grep ^label                       | # SELECT LABELS
                   cut -d "\"" -f 2                  | # CUT NAME FIELD
                   sed 's/[0-9]//g'                  | # REMOVE ALL NUMBERS
                   sort -u`                            # SORT/UNIQ
   do
       ALLOFTYPE=`sed 's/scape:label/\nlabel/g' ${SVG%%.*}.tmp | # PUT LABELS ON NEWLINE
                  grep ^label                                  | # SELECT LABELS
                  cut -d "\"" -f 2                             | # CUT NAME FIELD
                  grep $BASETYPE                               | # SELECT BASETYPE
                  sort -u`                                       # SORT/UNIQ
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
 (IFS=$'\n'; COUNT=1
  for KOMBI in `cat $KOMBILIST`
   do
      SVGOUT=${TMPID}_${COUNT}.svg
      head -n 1 ${SVG%%.*}.tmp                           >  $SVGOUT
      for  LAYERNAME in `echo $KOMBI | sed 's/ /\n/g'`
        do grep -n "label=\"$LAYERNAME\"" ${SVG%%.*}.tmp >> ${SVGOUT}.tmp
      done
      cat ${SVGOUT}.tmp | sort -n | cut -d ":" -f 2-     >> $SVGOUT
      echo "</svg>"                                      >> $SVGOUT
      sed -i "s/$BFOO/\n/g" ${SVGOUT}
      sed -i "s/$SFOO/ /g"  ${SVGOUT}
      inkscape --export-pdf=${SVGOUT%.*}.pdf $SVGOUT
      rm ${SVGOUT}.tmp;COUNT=`expr $COUNT + 1`
  done;)
# --------------------------------------------------------------------------- #
# LAYOUT PRINTSHEET
# --------------------------------------------------------------------------- #
  TMPTEX=${TMPID}.tex
  e () { echo $1 >> $TMPTEX ; };if [ -f $TMPTEX ]; then rm $TMPTEX ;fi
# --------------------------------------------------------------------------- #
  if   [ "$LAYOUT" == "EBL20" ];then
          X=8;Y=11;TEXCONFIG="nup=${X}x${Y},scale=.2,delta=3.6 3.6"
  elif [ "$LAYOUT" == "EBL30" ];then
          X=5;Y=8;TEXCONFIG="nup=${X}x${Y},scale=.3,delta=-1.5 -10"
  elif [ "$LAYOUT" == "EBL30NEU" ];then
          X=5;Y=8;TEXCONFIG="nup=${X}x${Y},scale=.3,delta=11.5 -10.8"
  elif [ "$LAYOUT" == "EBL40" ];then
          X=4;Y=6;TEXCONFIG="nup=${X}x${Y},scale=.41,delta=-7.3 -7.3"
  elif [ "$LAYOUT" == "EBL60" ];then
          X=3;Y=4;TEXCONFIG="nup=${X}x${Y},scale=.61,delta=-12 -2"
  fi
     ALL=`expr $X \* $Y`;PACK=`expr $X \* $Y`;CNT=$PACK

  e "\documentclass{scrbook}"
  e "\pagestyle{empty}"
  e "\usepackage{pdfpages}"
  e "\usepackage{geometry}"
  e "\geometry{paperwidth=210mm,paperheight=297mm}"
  e "\begin{document}"
  e "\includepdfmerge"
  e "[$TEXCONFIG,noautoscale,offset=0 0]"

# --------------------------------------------------------------------------- #
# COLLECT PDF FILES
# --------------------------------------------------------------------------- #
 #REFCNT=1
 #while [ $REFCNT -le $ALL ];
 # do
 #     PDF=`ls ${TMPID}_*.pdf | shuf -n 1`
 #     PDFALL=${PDFALL},${PDF}
 #     REFCNT=`expr $REFCNT + 1`
 #done
 #PDFALL=`echo $PDFALL | cut -d "," -f 2-`

 #PDFALL=`ls ${TMPID}_*.pdf | sed ":a;N;\\$!ba;s/\n/,/g"`

 #TODO: TAKE ALL PDFS AND FILL UP LAST PAGE.

  ALL=`expr $ALL \* 6`

  CNT=1
  while [ $CNT -le $ALL ];
   do
       PDF=`ls ${TMPID}_*.pdf | shuf -n 1`
       PDFALL=${PDFALL},${PDF}
       CNT=`expr $CNT + 1`
  done
  PDFALL=`echo $PDFALL | cut -d "," -f 2-`


# --------------------------------------------------------------------------- #
  e "{"$PDFALL"}"
  e "\end{document}"
# --------------------------------------------------------------------------- #
  pdflatex -output-directory=$TMPDIR $TMPTEX # > /dev/null

  PDFFINAL="drysticker.pdf"
  mv `echo $TMPTEX | sed 's/\.tex$/\.pdf/'` $OUTDIR/$PDFFINAL

# --------------------------------------------------------------------------- #
# REMOVE TEMP FILES
# --------------------------------------------------------------------------- #
  rm ${SVG%%.*}.tmp $KOMBILIST 
# =========================================================================== #
# CLEAN UP (MAKE SURE $TMPID IS SET FOR WILDCARD DELETE)
  if [ `echo ${TMPID} | wc -c` -ge 4 ] &&
     [ `ls ${TMPID}*.* 2>/dev/null | wc -l` -gt 0 ]
  then
        rm ${TMPID}*.*
  fi

# =========================================================================== #
  done
# =========================================================================== #


exit 0;

