#!/bin/bash

 #SRCURL="http://github.com/christop/DOK/raw/9895e8c/EDIT/130000_rw.txt"
 #SRCURL="https://raw.githubusercontent.com/christop/DOK/9895e8c/EDIT/130000_rw.txt"
 #SRCURL="http://www.forkable.eu/generators/r+w/do.sh"

  SRCURL="https://raw.githubusercontent.com/christop/DOK/fbd7aa9/EDIT/160125_forkable-tree.txt"

  TIMESTAMP=_`date +%y%m%d%H%M`
  OUT=`basename $SRCURL | sed "s/\.[a-z]*$/${TIMESTAMP}&/"`
  echo $OUT

     REF="REMEMBER.txt"
  TMPDIR=.
     TMP=${TMPDIR}/xx

  SRCURLHASH=`echo $SRCURL | md5sum`; CNT=1
  SRCURLID=`echo $SRCURLHASH | cut -c $((CNT))-$(($CNT + 2))`

  if [ `grep $SRCURL $REF | wc -l` -ge 1 ]; then
        SRCURLID=`grep $SRCURL $REF | cut -d ":" -f 1`
        echo "ALREADY IN LIST: ${SRCURLID}:${SRCURL}"
  else
        while [ `grep $SRCURLID $REF | wc -l` -ge 1 ]
         do
                SRCURLID=`echo $SRCURLHASH | #
                          cut -c $((CNT))-$(($CNT + 2))`
                CNT=`expr $CNT + 1`
        done
        echo "MAKING NEW ENTRY: ${SRCURLID}:${SRCURL}"
        echo "${SRCURLID}:${SRCURL}" >> $REF
  fi

  wget --no-check-certificate \
       -O ${TMP}.dump $SRCURL


  cat -n ${TMP}.dump       | #
  sed 's/^[ ]*[0-9]*/&:/'  | #
  sed "s/^/${SRCURLID}:/"  | # 
  tee > $OUT

  rm ${TMP}.dump



exit 0;
