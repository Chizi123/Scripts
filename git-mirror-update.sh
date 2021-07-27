#!/bin/bash

GIT_DIRECTORY=/Eduardo/git

for d in $GIT_DIRECTORY/*; do
    if grep -q "mirror = true" $d/config; then
	git -C "$d" remote update --prune
    fi
done
