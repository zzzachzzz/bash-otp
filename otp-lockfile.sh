#!/usr/bin/env bash

# Examples, all use password-based encryption:
# Encrypt file to file
#openssl enc -aes-256-cbc -pbkdf2 -salt -in file.txt -out file.txt.enc
# Decrypt file to stdout
#openssl enc -aes-256-cbc -pbkdf2 -d -salt -in file.txt.enc
# Decrypt file to file
#openssl enc -aes-256-cbc -pbkdf2 -d -salt -in file.txt.enc -out file.txt

INPUT_FILE="$1"

echo "WARNING: THIS WILL DELETE THE ORIGINAL FILE"

if [ ! -f "${INPUT_FILE}" ]; then
    echo "The file [${INPUT_FILE}] does not exist"
    exit 1
fi

read -s -r -p "Password to lock file: " PASSWORD1
read -s -r -p "Enter that password again: " PASSWORD2

if [[ "${PASSWORD1}" == "${PASSWORD2}" || "${PASSWORD2}" == "" ]]; then
    echo "${PASSWORD1}" | openssl enc -aes-256-cbc -pbkdf2 -salt -in "${INPUT_FILE}" -out "${INPUT_FILE}.enc" -pass stdin && rm "${INPUT_FILE}"
    echo "Decrypt this file using the following command:"
    echo "openssl enc -aes-256-cbc -pbkdf2 -d -salt -in ${INPUT_FILE}.enc -out ${INPUT_FILE}"
else
    echo "The passwords do not match; try that again"
    exit 1
fi

