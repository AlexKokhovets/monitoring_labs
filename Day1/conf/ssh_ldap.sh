#!/bin/bash
set -eou pipefail
IFS=$'\n\t'

result=$(ldapsearch -x '(&(objectClass=posixAccount)(uid='"$1"'))' 'sshPublicKey')
attrLine=$(echo "$result" | sed -n '/^ /{H;d};/sshPublicKey:/x;$g;s/\n *//g;/sshPublicKey:/p')

if [[ "$attrLine" == sshPublicKey::* ]]; then
  echo "$attrLine" | sed 's/sshPublicKey:: //' | base64 -d
elif [[ "$attrLine" == sshPublicKey:* ]]; then
  echo "$attrLine" | sed 's/sshPublicKey: //'
else
  exit 1
fi
