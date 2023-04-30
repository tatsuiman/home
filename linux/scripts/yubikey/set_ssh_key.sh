#!/bin/bash -e
SN=$(yubico-piv-tool -a status | grep "Serial Number:" | awk '{print $3}')
echo "SN: $SN"
read -p "pin:" -s pin
echo
read -p "current mgmt key:" -s current_mgmt_key
echo
ykman piv generate-key --algorithm RSA2048 -m $current_mgmt_key -P $pin --touch-policy DEFAULT 9a /tmp/pub.pem
ykman piv generate-certificate -m $current_mgmt_key -P $pin -s "SSH Key ($SN)" --valid-days 3650 9a /tmp/pub.pem

ssh-keygen -D opensc-pkcs11.so
