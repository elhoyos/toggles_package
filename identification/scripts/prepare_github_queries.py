import sys
import re
from csv_lib import csv_rows

# Prints BigQuery Github queries from a template substituted with data from a csv.
# Each row in the csv is a query.
#
# Usage:
# python prepare_github_queries.py trace-sets.csv query_template.sql

if __name__ == '__main__':
  csv_filename = sys.argv[1]
  template_filename = sys.argv[2]

  for row, template in csv_rows(csv_filename, template_filename):
    data = {}
    content_sql_traceset = row['Content SQL Trace Set (GitHub + BigQuery)']
    if content_sql_traceset.strip() == '':
      continue

    data['library'] = "'" + row['Library'] + "'"
    data['library_language'] = "'" + row['Languages'] + "'"
    data['where_language_in'] = "language IN('" + row['Languages'].replace(',', "','") + "')"
    data['where_path_matches'] = row['Path SQL Trace Set (GitHub + BigQuery)']
    data['where_content_matches'] = re.sub(r'\n', '\n    ', content_sql_traceset, flags=re.MULTILINE)
    print(template.substitute(data))
