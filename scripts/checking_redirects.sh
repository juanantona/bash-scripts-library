#!/bin/bash

HOST="http://www.google.com"
INPUT_FILE="redirects_input.csv"
OUTPUT_FILE="redirects_output.txt"

# redirect stdout/stderr to a file
exec &> $OUTPUT_FILE

(
  cd $(dirname $0)

  TEST_NUMBER=1
  TEST_OK=0
  TEST_FAIL=0
  cat $INPUT_FILE | tr '\r\n' '\n' | egrep -v '^#' | ( while read line  
    do
      ORIGIN_URL=$(echo "$line" | cut -d";" -f1)
      EXPECTED_URL=$(echo "$line" | cut -d";" -f2)
      
      if [ "$ORIGIN_URL" != "" ]
      then
        REDIRECTED_URL=$(curl --silent \
          -Ls \
          -o /denull \
          -w %{url_effective} \
          "$HOST$ORIGIN_URL"
        )
        
        REDIRECTED_URL_WITHOUT_HOST=${REDIRECTED_URL/$HOST/} 
        REDIRECTED_URL_WITHOUT_PARAMS=$(echo "$REDIRECTED_URL_WITHOUT_HOST" | cut -d"?" -f1) 

        if [ "$EXPECTED_URL" == "$REDIRECTED_URL_WITHOUT_PARAMS" ]
        then
          echo "URL $TEST_NUMBER   : [  OK  ] > ORIGIN_URL   : $ORIGIN_URL"
          TEST_OK=$((TEST_OK+1))
        else
          echo "URL $TEST_NUMBER   : [ FAIL ]" 
          echo " > ORIGIN_URL     : $ORIGIN_URL" 
          echo " > EXPECTED_URL   : $EXPECTED_URL" 
          echo " > REDIRECTED_URL : $REDIRECTED_URL_WITHOUT_PARAMS"
          TEST_FAIL=$((TEST_FAIL+1))
        fi

        TEST_NUMBER=$((TEST_NUMBER+1))
      fi
    
    done
    echo "TEST OK   : [ $TEST_OK ]" 
    echo "TEST FAIL : [ $TEST_FAIL ]" 
  )    
)
