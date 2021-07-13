#!/bin/bash

#GIT_DIRECTORY=/Eduardo/git
GIT_DIRECTORY=/home/joel/Downloads/temp

for d in $GIT_DIRECTORY/*; do
    if ! grep -q "mirror = true" $d/config; then
	git -C $d remote update
    fi
done
