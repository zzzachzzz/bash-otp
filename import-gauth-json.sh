#!/usr/bin/env bash

# For use with https://github.com/krissrex/google-authenticator-exporter

jsonfile=$1

read -s -r -p "Password to lock file: " password1
read -s -r -p "Enter that password again: " password2

if [[ "${password1}" != "${password2}" && "${password2}" != "" ]]; then
    echo "The passwords do not match; try that again"
    exit 1
fi

jq -c '.[]' $jsonfile | while read item; do
  name="$(echo $item | jq -r '.name')"
  totpSecret="$(echo $item | jq -r '.totpSecret')"

  input_file="./tokenfiles/${name}"
  echo "$totpSecret" >> "$input_file"

  echo "${password1}" | openssl enc -aes-256-cbc -pbkdf2 -salt -in "$input_file" -out "${input_file}.enc" -pass stdin && rm "$input_file"
done
