#!/bin/bash

  EDIT="treetest.txt"
  EDIT="/home/christoph/2016/160125--DOK-CUTUP/EDIT/130000_rw/130000_rw_1601251934.txt"
  REF="REMEMBER.txt"
  MDSHACTION="% QUAVERBATIM"


 ( IFS=$'\n';NEWRANGE="Y";R=$RANDOM   # PRESET

  for LINE in  `cat $EDIT           | # DISPLAY $EDIT
                sed 's/^[ \t]*$/X/' | # MAKE EMPTY X
                grep -n ""`           # NUMBER LINES
   do
        N=`echo $LINE | cut -d ":" -f 1`  # STORE LINE NUMBER
     LINE=`echo $LINE | cut -d ":" -f 2-` # AND REMOVE LINE NUMBER

     if [ Y`echo $LINE                             | # ECHO $LINE
            sed "s/^[a-f0-9]\{3\}:[0-9 ]*:.*$/$R/" | # REPLACE 'CUTUP' PATTERN WITH $R
            grep "^${R}$"` == "Y${R}" ]              # IF MATCH
     then
             SRCID=`echo $LINE       | # DISPLAY LINE
                    cut -d ":" -f 1`   # CUT FIELD 1 (= SRCID)
            NEXTSRCID=`sed -n "$((N + 1))p" $EDIT | # DISPLAY LINE AFTER LINE
                       cut -d ":" -f 1`             # CUT FIELD 1 (= SRCID)
            SRCURL=`grep $SRCID $REF | # FIND SRCID IN REFERENCE
                    head -n 1        | # FIRST LINE ONLY
                    cut -d ":" -f 2-`  # CUT FIELD 1 (= SRCURL)
            THISLINUM=`echo $LINE       | # DISPLAY LINE
                       cut -d ":" -f 2  | # CUT FIELD 2 (= LINE NUMBER)
                       sed 's/[ ]*//g'`   # REMOVE SPACES
            NEXTLINUM=`sed -n "$((N + 1))p" $EDIT        | # DISPLAY LINE AFTER LINE
                       cut -d ":" -f 2  | sed 's/[ ]*//g'` # CUT FIELD 2 / REMOVE SPACES

            if [ R$NEWRANGE == RY ]; then
                 F=$THISLINUM
            fi

         if [ Y`sed -n "$((N - 1))p" $EDIT             | # DISPLAY PREVIOUS LINE
                sed "s/^[a-f0-9]\{3\}:[0-9 ]*:.*$/$R/" | # REPLACE 'CUTUP' PATTERN WITH $R
                grep "^${R}$"` != "Y${R}" ]              # IF NO MATCH
         then
              echo "% ---------------- "
         fi

            if [ "X$NEXTLINUM" != X`expr $THISLINUM + 1` ] ||
               [ "X$SRCID" != "X$NEXTSRCID" ]; then
                  if [ $F -eq $THISLINUM ]; then
                       echo "% $SRCURL $F"
                  else
                       echo "% $SRCURL ${F}-${THISLINUM}"
                  fi
                  NEWRANGE="Y"
            else
                  NEWRANGE="N"
            fi

         if [ Y`sed -n "$((N + 1))p" $EDIT             | # DISPLAY NEXT LINE
                sed "s/^[a-f0-9]\{3\}:[0-9 ]*:.*$/$R/" | # REPLACE 'CUTUP' PATTERN WITH $R
                grep "^${R}$"` != "Y${R}" ]              # IF NO MATCH
         then
              echo "${MDSHACTION}:"
         fi
     else
          echo $LINE | sed 's/^X$//g'
     fi
 done

 )


exit 0;

