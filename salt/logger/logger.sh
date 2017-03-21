#!/usr/bin/env bash
set -euf -o pipefail

for log in /var/log/*.log
do
  echo "$(date '+%d/%m/%Y %H:%M:%S')|$log|$(grep -c ^ "$log")" >> /root/counts.log
done

exit 0
