import sys
import csv
from collections import OrderedDict
from csv_lib import parse_csv_line

# Takes a csv of toggled repositories via stdin and augments them with data from another
# csv file.
#
# A new augments csv is printed.
#
# Usage:
# $ cat results/toggled_repositories_bare.csv | python augment_toggled_repos.py repositories_data.csv > results/toggled_repositories.csv

in_csv_fieldnames = ['repo_name', 'path', 'language', 'size_bytes', 'library', 'library_language', 'last_commit_ts', 'forked_from']

def load_repositories_data(repositories_data_filename):
    with open(repositories_data_filename) as csvfile:
        reader = csv.DictReader(csvfile)
        repos_data = { '' + row['repo_name']: row for row in reader }
        repos_data['__fieldnames__'] = reader.fieldnames
        return repos_data

if __name__ == '__main__':
    repositories_data_filename = sys.argv[1]
    repositories_data = load_repositories_data(repositories_data_filename)

    out_csv_fieldnames = OrderedDict([(key, None) for key in in_csv_fieldnames])
    out_csv_fieldnames.update(OrderedDict([(key, None) for key in repositories_data['__fieldnames__']]))
    writer = csv.DictWriter(sys.stdout, out_csv_fieldnames)

    for line, i, row in parse_csv_line(sys.stdin):
        if i == 1:
            writer.writeheader()
            continue

        augmented_row = row.copy()
        repo_data = repositories_data.get(row['repo_name'])
        if repo_data:
            augmented_row.update(repo_data)

        writer.writerow(augmented_row)
