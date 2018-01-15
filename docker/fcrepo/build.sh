#!/usr/bin/env bash
FAILURE=0

docker build --force-rm --pull -t cora-fedora:3.8.1 . || FAILURE=1

if [ $FAILURE -eq 1 ]
then
  echo "Docker build failed"
  exit 1
fi
