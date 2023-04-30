#!/bin/bash -e

read -p "current mgmt key:" -s current_mgmt_key
if [[ -z "$current_mgmt_key" ]]; then
  current_mgmt_key="010203040506070801020304050607080102030405060708"
fi
new_mgmt_key=$(openssl rand -hex 24)
SN=$(yubico-piv-tool -a status | grep "Serial Number:" | awk '{print $3}')

ykman piv access change-management-key -n $new_mgmt_key -m $current_mgmt_key
echo "changed: $new_mgmt_key"

echo "$(date '+%Y-%m-%d %H:%M:%S'),$SN,$new_mgmt_key" >> mgmt_key.csv

echo "Saved: mgmt_key.csv"
