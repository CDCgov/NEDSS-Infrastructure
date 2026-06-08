#!/bin/bash

# convert unix EOL to \r (which shows up as "^M" in vi)
#

TMP_FILE_PREFIX=$1

tr '\n' '\r' < ${TMP_FILE_PREFIX}.hl7 > ${TMP_FILE_PREFIX}_reol.hl7

