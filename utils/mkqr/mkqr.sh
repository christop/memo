#!/bin/bash

  TMPID=XX

  QRDEKOSRC="../../EDIT/151007_qrdeko-simple.svg"
  SHORTURLBASE="http://lfkn.de"
  QRDEKO=qrnow

  function shortref() {

      IDP1=`echo $* | cut -d " " -f 1 | #
            sed 's/ //g' | md5sum  | #
            base64 | cut -c 1-3`  # 
      IDP2=`echo $* | cut -d " " -f 2- | #
            sed 's/ //g' | md5sum  | #
            base64 | cut -c 4-5` # 
     REFID="${IDP1}${IDP2}"

     THISFLAG=`echo "$*" | sed 's/^[ \t]*//'`
     echo "$SHORTURLBASE/$REFID"
  }

   QRID=`shortref $*`
   QRID=`echo $QRID | rev | cut -d "/" -f 1 | rev`
  QRTXT=`echo $QRID | tr [:lower:] [:upper:]`
  QURL="$SHORTURLBASE/$QRTXT"

  QRPDF=${TMPID}TMP.pdf

  SCALE="scale(0.1,-0.1)"
  MOVE="translate(55,145)"
  TRANSFORMQR="transform=\"$MOVE$SCALE\""

# SELECT LAYERS: ONE FOR EACH UNIQUE NAME
# ---------------------------------------------------------------------------- #
  sed ":a;N;\$!ba;s/\n/ /g" $QRDEKOSRC  | # REMOVE ALL LINEBREAKS
  sed 's/<g/\n<g/g'                     | # RESTORE GROUP OPEN + NEWLINE
  sed '/groupmode="layer"/s/<g/4Fgt7R/g'| # PLACEHOLDER FOR LAYERGROUP OPEN
  sed ':a;N;$!ba;s/\n/ /g'              | # REMOVE ALL LINEBREAKS
  sed 's/4Fgt7R/\n<g/g'                 | # RESTORE LAYERGROUP OPEN + NEWLINE
  sed 's/display:none/display:inline/g' | # MAKE VISIBLE EVEN WHEN HIDDEN
  tee head.tmp                          | # DUMP NOW TO EXTRACT HEAD LATER
  tail -n +2                            | # REMOVE HEAD (=FIRST LINE)
  sed 's/<\/svg>//g'                    | # REMOVE CLOSING TAG
  grep -n ""                            | # NUMBER LINES
  sed "s/^.*$/&|&/g"                    | # DOUBLE CONTENT FOR ANALYSIS
  sed "s/:label/\nX1X/"                 | # MARK LABEL (=NAME)
  grep -v ":label=\"XX_"                | # IGNORE XX LAYERS
  grep  "^X1X"                          | # SELECT MARKED
  shuf                                  | # SHUFFLE
  sort -u -t\" -k1,2                    | # SELECT ONE FOR EACH LABEL
  cut -d "|" -f 2-                      | # SELECT SECOND/UNTOUCHED CONTEN
  sort -n -u -t: -k1,1                  | # SORT ACCORDING TO LINE NUMBER
  cut -d ":" -f 2-                      | # REMOVE LINENUMBER
  tee  > layers.tmp                       # WRITE TO FILE
# ---------------------------------------------------------------------------- #

  head -n 1 head.tmp                      >  ${QRDEKO}.svg
  cat layers.tmp | sed "s/VWXYZ/$QRTXT/g" >> ${QRDEKO}.svg

  echo "$QURL" | qrencode -iv 1 -t EPS -o ${TMPID}TMP${QRID}.eps

  inkscape --export-plain-svg=${TMPID}TMP${QRID}.svg \
           ${TMPID}TMP${QRID}.eps

  echo "<g $TRANSFORMQR>"  >> ${QRDEKO}.svg
  sed ':a;N;$!ba;s/\n/ /g' ${TMPID}TMP${QRID}.svg | \
  tr -s ' ' | sed 's/</\n&/g' | #
  grep "^<path"            >> ${QRDEKO}.svg
  echo "</g>"              >> ${QRDEKO}.svg
  echo "</svg>"            >> ${QRDEKO}.svg

  sed -i 's/sodipodi:insensitive="[^"]*"//g' ${QRDEKO}.svg

  inkscape --export-pdf=$QRPDF  \
           --export-text-to-path \
           ${QRDEKO}.svg

  rm ${TMPID}TMP* *.tmp


exit 0;
