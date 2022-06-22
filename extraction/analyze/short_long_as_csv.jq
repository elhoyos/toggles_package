# Generates a csv file with all the toggles with their expected longevity set
# 
# Usage
# $ jq --slurp --raw-output --from-file short_long_as_csv.jq done/*.json > short_long.csv

. |
flatten |
[
  "name", "repo_name", "all_routers_removed",
  "weeks_survived", "expected_longevity",
  "expected_longevity_comment"] as $cols |
map(
  select(
    (has("group_as") | not)
  ) as $row |
  $cols |
  map($row[.] | if type == "array" then tojson else . end)
) as $rows |
$cols, $rows[] |
@csv
