#!/bin/bash
set -ue
FILE=CHANGELOG.md
LINES=$(grep -n "^##" -m 2 "${FILE}" | sed -e 's/:.*//g'| sed -z "s/\n/,/g" | sed "s/,$//")

sed -n "${LINES}p" "${FILE}" | sed -e "/^$/d" -e "/^##/d"
