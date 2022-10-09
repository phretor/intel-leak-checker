#! /bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'

if [ "$#" -ne 1 ]
then
  printf "\n${RED}Usage: ./checker.sh <path/to/rom.bin>\n"
  exit 1
fi


xxd -g 0 -c 0 -ps "$1" | grep -qioE -f pubkeys/keys.rsa && \
    printf "\n${RED}Keys found: you're likely affected.\n" || 
    printf "\n${GREEN}No keys found: you may not be affected\n"
