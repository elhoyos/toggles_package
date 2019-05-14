import sys
import re
import string
from csv_lib import csv_rows

# Prints BigQuery Libraries.io queries from a template substituted with data from a csv.
# Each row in the csv is a query.
#
# Usage:
# python prepare_librariesio_queries.py trace-sets.csv query_template_librariesio.sql

if __name__ == '__main__':
  csv_filename = sys.argv[1]
  sql_template_filename = sys.argv[2]
  struct_template = string.Template('  STRUCT($library AS library, $artifact_name AS artifact_name, $platform AS platform, $languages AS languages)')

  struct_libraries = []
  for row, template in csv_rows(csv_filename, sql_template_filename):
    package_manager_entries = row['Name in PM']
    if package_manager_entries.strip() == '':
      continue

    library_name = row['Library']
    languages = row['Languages']
    for artifact in package_manager_entries.splitlines():
      entries = artifact.split(',')
      library = {
        'library': "'" + library_name + "'",
        'artifact_name': "'" + entries[0] + "'",
        'platform': "'" + entries[1] + "'",
        'languages': "'" + languages + "'"
      }
      struct_libraries.append(struct_template.substitute(library))

  print(template.substitute({
    'struct_libraries': ',\n'.join(struct_libraries)
  }))
