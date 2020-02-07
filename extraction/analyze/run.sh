#!/bin/bash

# Usage:
#
# Analyze extracted toggles.
#
# Prepre and gzip output data
# REPOS_STORE=repositories EXTRACTION=toggles COMPRESS=true ./run.sh refocus MTC

set -e

echo "<<<<< Analyze Toggles >>>>>"

BASE=`dirname "$0"`
OUTPUT_BASE_DIR="$BASE/../analysis"
OUTPUT_RAW="$OUTPUT_BASE_DIR/raw"
OUTPUT_MERGED="$OUTPUT_BASE_DIR/merged"
OWNER_REPO_SEPARATOR="__"
ANALYZERS_DIR="$BASE/analyzers"
MERGE_SCRIPT="$BASE/../../identification/scripts/merge-results.sh"

echo "Cleaning up..."
rm -rf "$OUTPUT_RAW" "$OUTPUT_MERGED"

for repo in "$@"
do
  output="$OUTPUT_RAW/$repo"
  rm -rf "$output"
  mkdir -p "$output"
  repo_name=`echo "$repo" | sed "s/$OWNER_REPO_SEPARATOR/\//"`

  echo "Processing $repo_name"

  echo "Copying extraction to $output..."
  file=$repo.json
  cp "$EXTRACTION/$file" "$output"

  echo "Preparing data for analysis..."
  echo "$REPOS_STORE/$repo"
  node "$ANALYZERS_DIR/commits.js" $repo_name "$output/$file" "$REPOS_STORE/$repo" > "$output/commits.csv"
  node "$ANALYZERS_DIR/loc.js" $repo_name "$output/$file" "$REPOS_STORE/$repo" > "$output/loc.csv"
  node "$ANALYZERS_DIR/counts-per-type-history.js" "$output/$file" > "$output/counts-per-type-history.csv"
  node "$ANALYZERS_DIR/survival.js" $repo_name "$output/$file" "$REPOS_STORE/$repo" > "$output/survival.csv"
  node "$ANALYZERS_DIR/operations-per-type.js" $repo_name "$output/$file" > "$output/operations-per-type.csv"

  if [[ ! -z "$COMPRESS" ]]
  then
    cd "$output"
    gzip -f *.json *.csv
  fi
done

mkdir -p "$OUTPUT_MERGED"
declare -a merge_files=("commits" "loc" "operations-per-type")
for filename in "${merge_files[@]}"
do
  echo "Merging $filename files..."
  sh "$MERGE_SCRIPT" "$OUTPUT_RAW/*/$filename.csv" > "$OUTPUT_MERGED/$filename.csv"
done

echo "Done"
