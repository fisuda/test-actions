#!/bin/bash

# MIT License
#
# Copyright (c) 2023 Kazuhito Suda
#
# This file is part of FIWARE Small Bang
#
# https://github.com/lets-fiware/FIWARE-Small-Bang
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -ue

cd "$(dirname "$0")"
cd ..

TAG=$(cat VERSION)
TAG="v${TAG##*=}"
VER=${TAG//v/}
echo "TAG: ${TAG}"
echo "VER: ${VER}"

if echo "${TAG}" | grep -q "-next"
then
  exit 0
fi

if git tag | grep -q "${TAG}"
then
  exit 0
fi

AUTHOR_NAME=$(jq -r '.pull_request.merged_by.login' "$GITHUB_EVENT_PATH")
AUTHOR_EMAIL=$(jq -r '.pull_request.merged_by.email' "$GITHUB_EVENT_PATH")

git config user.name "${AUTHOR_NAME}"
git config user.email "${AUTHOR_EMAIL}"
git tag "${TAG}"
git push origin "${TAG}"

NAME=${REPO##*/}

echo "NAME: ${NAME}"
echo "REPO: ${REPO}"

FILE=CHANGELOG.md
LINES=$(grep -n "^##" -m 2 "${FILE}" | sed -e 's/:.*//g'| sed -z "s/\n/,/g" | sed "s/,$//")
CHANGE_LOG=$(sed -n "${LINES}p" "${FILE}" | sed -e "/^$/d" -e "/^##/d" | sed -z "s/\n/\\\\n/g")
echo "${CHANGE_LOG}"

RES=$(curl -X POST \
     -H "Authorization: token ${GITHUB_TOKEN}" \
     -d "{ \"tag_name\": \"${TAG}\", \"name\": \"${NAME//-/ } ${TAG}\", \"body\": \"${CHANGE_LOG}\"}" \
     "https://api.github.com/repos/${REPO}/releases")

curl -X POST \
     -H "Authorization: token ${GITHUB_TOKEN}" \
     -H "Accept: application/vnd.github.v3+json" \
     https://api.github.com/repos/fisuda/test-actions/actions/workflows/publish.yml/dispatches \
     -d '{"ref":"main"}'
