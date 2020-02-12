# Generates a csv file with all the toggles and their categories
# 
# Usage
# $ jq --slurp --raw-output --from-file categorized_as_csv.jq done/*.json > categories.csv

. |
flatten |
["name", "repo_name", "all_routers_removed", "weeks_survived", "category", "category_comment"] as $cols |
map(
  select(
    .category_comment != "--WAFFLE-HARD-COPY--" and
    (has("group_as") | not)
  ) as $row |
  $cols |
  map($row[.])
) as $rows |
$cols, $rows[] |
@csv
