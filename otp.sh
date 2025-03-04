#!/usr/bin/env bash

# Openssl encrypt/decrypt examples
# Encrypt file to file
#openssl enc -aes-256-cbc -salt -in file.txt -out file.txt.enc
# Decrypt file to stdout
#openssl enc -aes-256-cbc -d -salt -in file.txt.enc
# Decrypt file to file
#openssl enc -aes-256-cbc -d -salt -in file.txt.enc -out file.txt

# Init
TOKENFILES_DIR="${BASH_OTP_TOKENFILES_DIR:-$( dirname ${0} )/tokenfiles}"
TOKENFILES_DIR_MODE="$( ls -ld ${TOKENFILES_DIR} | awk '{print $1}'| sed 's/.//' )"
U_MODE="$( echo $TOKENFILES_DIR_MODE | awk  -F '' '{print $1 $2 $3}' )"
G_MODE="$( echo $TOKENFILES_DIR_MODE | awk  -F '' '{print $4 $5 $6}' )"
A_MODE="$( echo $TOKENFILES_DIR_MODE | awk  -F '' '{print $7 $8 $9}' )"

if [ "$( echo $G_MODE | grep -E 'r|w|x' )" -o "$( echo $A_MODE | grep -E 'r|w|x' )" ]; then
    echo "Perms on [$TOKENFILES_DIR] are too permissive. Try 'chmod 700 $TOKENFILES_DIR' first"
    exit 1
fi

tokenfile="$1"
if [ -z "$tokenfile" ]; then echo "Need token file"; exit 1; fi

if [[ -f "$tokenfile" ]]; then
    read -s -r -p "Password: " PASSWORD
    TOKEN=$(echo $PASSWORD | openssl enc -aes-256-cbc -pbkdf2 -d -salt -pass stdin -in "$tokenfile")
    if [ $? -ne 0 ]; then
      echo "ERROR: Unable to decrypt. Exiting"
      exit 1
    fi
else
    echo "ERROR: Key file [$tokenfile] doesn't exist"
    exit 1
fi

echo
D=0
D="$( date  +%S )"
if [ $D -gt 30 ] ; then D=$( echo "$D - 30"| bc ); fi
if [ $D -lt 0 ] ; then D="00"; fi

while true; do
    D="$( date  +%S )"
    X=$( oathtool --totp -b "$TOKEN" )
    if [ $D = '59'  -o $D = '29' ] ; then
        printf "$D: $X\n"
    else
        printf "$D: $X\r"
    fi
    OS=$( uname )
    if [[ $OS = "Darwin" ]]; then
        printf $X | pbcopy
    elif [[ $OS = "Linux" ]]; then
        printf $X | xclip -sel clip
    fi
    sleep 1
done
