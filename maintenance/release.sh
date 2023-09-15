#!/bin/bash

if [ "`echo "refs/tags/v0.2.0" | grep "^refs/tags/v"`" ]; then
  echo "ok"
fi

