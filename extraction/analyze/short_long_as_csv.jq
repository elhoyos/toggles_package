# Generates a csv file with all the toggles with their expected longevity set
# 
# Usage
# $ jq --slurp --raw-output --from-file short_long_as_csv.jq done/*.json > short_long.csv

. |
flatten |
[
  "name", "repo_name", "all_routers_removed",
  "weeks_survived", "category", "expected_longevity",
  "all_routers_removed"] as $cols |
map(
  select(
    .expected_longevity != null and
    (has("group_as") | not)
  ) as $row |
  $cols |
  map($row[.])
) as $rows |
$cols, $rows[] |
@csv
