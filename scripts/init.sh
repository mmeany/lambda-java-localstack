#!/usr/bin/env bash

WORK="./.work"

if [[ -d ${WORK} ]]; then
  rm -Rf "${WORK}"
fi

mkdir -p "${WORK}"
