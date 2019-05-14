import sys
import csv
import string

# Prints a query to augment the data of the repositories of a given csv.
#
# Usage:
# $ python prepare_augment_repos_query.py repositories.csv augment_repos_query_template.sql > augment_repos_data.sql

if __name__ == '__main__':
    csv_filename = sys.argv[1]
    template_filename = sys.argv[2]

    with open(template_filename, 'r') as templatefile:
        template = string.Template(templatefile.read())

        with open(csv_filename, 'r') as csvfile:
            reader = csv.DictReader(csvfile)

            values = []
            # value = "      ('{0}')"
            value = "      STRUCT('{0}' AS repo_name)"
            for row in reader:
                values.append(value.format(row['repo_name']))

            print(template.substitute({ 'values': ',\n'.join(values) }))