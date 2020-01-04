#!/bin/bash

# Usage:
#
# Analyze extracted toggles.
#
# Prepre and gzip output data
# REPOS_STORE=repositories COMPRESS=true ./analyze.sh refocus MTC

set -e

echo "<<<<< Analyze Toggles >>>>>"

OUTPUT_BASE_DIR="analysis"
OUTPUT_RAW="$OUTPUT_BASE_DIR/raw"
OUTPUT_MERGED="$OUTPUT_BASE_DIR/merged"
EXTRACTION="/home/jim/research/bulktractor/analysis/raw"
OWNER_REPO_SEPARATOR="__"
MERGE_SCRIPT="../identification/scripts/merge-results.sh"

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
  node rq1-commits.js $repo_name "$output/$file" "$REPOS_STORE/$repo" > "$output/rq1-commits.csv"
  node rq1-loc.js $repo_name "$output/$file" "$REPOS_STORE/$repo" > "$output/rq1-loc.csv"
  node rq2-counts-per-type-history.js "$output/$file" > "$output/rq2-counts-per-type-history.csv"
  node rq3-survival.js $repo_name "$output/$file" "$REPOS_STORE/$repo" > "$output/rq3-survival.csv"
  node rqX-operations-per-type.js $repo_name "$output/$file" > "$output/rqX-operations-per-type.csv"

  if [[ ! -z "$COMPRESS" ]]
  then
    cd "$output"
    gzip -f *.json *.csv
  fi
done

declare -a merge_files=("rq1-commits" "rq1-loc" "rqX-operations-per-type")
for filename in "${merge_files[@]}"
do
  echo "Merging $filename files..."
  sh "$MERGE_SCRIPT" "$OUTPUT_RAW/*/$filename.csv" > "$OUTPUT_MERGED/$filename.csv"
done

echo "Done"
