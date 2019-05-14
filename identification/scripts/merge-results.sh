#!/bin/bash

# Merge a set of csv results files into one csv file
#
# Usage:
# $ merge-results.sh "results/raw/results*-github.csv" > results/normalized/results-github.csv

# TODO: fix merging with a line overlapping on top of the last when the
# last line of previous files does not end in a newline character.
# (head -1 `ls -1 $1 | head -1` && for f in $1; do tail -n +2 "$f"; done)
(head -1 `ls -1 $@ | head -1` && for f in $@; do tail -n +2 "$f"; done)
