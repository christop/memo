#!/bin/bash

 EDIT="dev.txt"
 REF="REFERENCES.txt"
 MDSHACTION="% QUAVERBATIM"


 echo ""
 echo "% ------------------------- "

 ( IFS=$'\n';CNT=0;PREV=0;

  for LINE in  `cat $EDIT`
   do
     SRCID=`echo $LINE       | #
            cut -d ":" -f 1`   #
    SRCURL=`grep $SRCID $REF | #
            head -n 1        | # 
            cut -d ":" -f 2-`  #
     LINUM=`echo $LINE       | #
            cut -d ":" -f 2  | #
            sed 's/[ ]*//g'`   #

   # FOR THE VERY FIRST TIME           #
   # --------------------------------- #
   if [ $CNT -eq 0 ]; then
        F=$LINUM; LINES="${LINUM}"
    else
     if [ "$LINUM" -eq `expr $PREV + 1` ]; then
           LINES="${F}-${LINUM}"
     else
           echo "% $SRCURL ${LINES}"           
           F=$LINUM
           LINES="${LINUM}"
     fi
    fi

     PREV="$LINUM"
     CNT=`expr $CNT + 1`
 done

 echo "% $SRCURL ${LINES}"
 echo "${MDSHACTION}:"
 echo ""

 )


exit 0;

