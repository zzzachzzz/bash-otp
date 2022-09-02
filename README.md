# bash-otp

## Changes made in this fork
* Allow supplying password to otp scripts with stdin. Example use case: `fn_get_pass | ./otp.sh tokenfiles/file.enc`
* Specify token file by path, rather than by filename (allows for tab completion)
* Use `-pbkdf2` with all `openssl enc` operations (see `man openssl enc`)
* Supply passwords to `openssl` with stdin instead of temp files
* Remove functionality for reading tokens from plaintext files, assume encrypted
* Supply a script `import-gauth-json.sh` that imports from Google Authenticator with the help of [krissrex/google-authenticator-exporter](https://github.com/krissrex/google-authenticator-exporter)

### Suggested helper configuration
I opted to store the password used for encrypting my token files in my password manager, Bitwarden. Thus, my config uses the Bitwarden CLI. You can achieve something similar with the LastPass CLI, KeePass, etc.
```bash
export BASH_OTP_TOKENFILES_DIR="/home/zach/tokenfiles"

function bwunlock() { export BW_SESSION=$(bw unlock --raw) }

function otpgetpass() {
  if [ $(bw status | jq -r '.status') != 'unlocked' ]; then
    echo "Bitwarden is locked" >&2
    return 1
  fi
  bw get password "<id-of-vault-item>"
}

function otp() {
  local pass
  pass="$(otpgetpass)" || return $?
  echo "$pass" | ~/git/bash-otp/otp.sh "$@"
}

function otpadd() {
  local pass
  pass="$(otpgetpass)" || return $?
  echo "$pass" | ~/git/bash-otp/otp-lockfile.sh "$@"
}
```

## Original readme

One-Time Password generator for CLI using bash, oathtool.

Automatically copys the token into your computer's copy buffer (MacOS only atm)

This is basically "Authy for the CLI"

This script supports both encrypted and plain-text token files, but my reccomendation is to use encryption.

### Requirements

* oathtool (http://www.nongnu.org/oath-toolkit/)
* OpenSSL
* xclip (Linux)

## Description

Set of bash shell scripts to generate OTP *value* from token using TOTP.

### Usage

First ensure that there is a directory "tokenfiles" in the main dir where the script resides, and that this directory's permissions are set to 700.

1. Create token file and encrypt it. Resulting file, "tokenfiles/tokenname.enc", is an encrypted file containing the token
  1. Put your token in a plaintext file in the tokenfiles/ directory:
  ```bash
  $ echo "1234567890abcdef" > tokenfiles/tokenname
  ```
  
  1. Encrypt the file with the included shell script:
  ```bash
  $ ./otp-lockfile.sh tokenfiles/tokenname
  Password: (enter a good password)
  ```
  
  1. Confirm it worked:
  ```bash
  $ ls tokenfiles/
  tokenname.enc
  ```

1. Run otp.sh; will produce roughly the following output:
  ```
$ ./otp.sh tokenname
Password:
02: 123456
  ```

The number on the left is the seconds counter; a new TOTP token is generated every 30 seconds.

The number on the right is the 6-digit One-Time Password.

This will be copied directly into the paste buffer. Just press "Command-V" (or "CTRL-V" on Linux) to paste into a login dialog.


In case you want "tokenfiles" to reside in a different location, you can tell otp.sh to use this directory instead by exporting the `BASH_OTP_TOKENFILES_DIR` variable like so:

  ```bash
  $ export BASH_OTP_TOKENFILES_DIR=/path/to/secure/tokenfiles/dir
  ```

## Contents

* Script to do the actual value generation
* Script to encrypt the token in a file
* Script to decrypt same
* Empty "tokenfiles/" directory

