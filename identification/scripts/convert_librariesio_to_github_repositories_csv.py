import sys
import csv

# Converts a libraries.io csv into a github csv. Input files are the
# results of executing bigquery_{github,librariesio}.sql
#
# Usage:
# $ python convert_librariesio_to_github_repositories_csv.py results/raw/results-20181213-203121-librariesio.csv > results/normalized/results-20181213-203121-librariesio.csv

fieldnames = ['repo_name', 'path', 'language', 'size_bytes', 'library', 'library_language', 'last_commit_ts', 'forked_from']

if __name__ == '__main__':
  in_csv_filename = sys.argv[1]
  out_csv_filename = sys.stdout

  with open(in_csv_filename, 'r') as csv_file:
    reader = csv.DictReader(csv_file)
    writer = csv.DictWriter(out_csv_filename, fieldnames=fieldnames, lineterminator='\n')

    writer.writeheader()
    for row in reader:
      data = {key: None for key in fieldnames}
      data['repo_name'] = row['name_with_owner']
      data['forked_from'] = row['fork_source_name_with_owner']
      data['language'] = row['language']
      data['size_bytes'] = row['bytes']
      data['library'] = row['library']
      data['library_language'] = row['library_language']
      writer.writerow(data)