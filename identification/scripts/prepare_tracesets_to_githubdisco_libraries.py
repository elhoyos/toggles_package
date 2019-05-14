import sys
import re
from csv_lib import csv_rows

# Prints BigQuery Github queries from a template substituted with data from a csv.
# Each row in the csv is a query.
#
# Usage:
# $ python prepare_tracesets_to_githubdisco_libraries.py ../trace-sets.csv githubdisco_libraries_template.py > ../githubdisco/libraries.py

def print_header(): 
    print('LIBRARIES = [')

def print_footer(): 
    print(']')

if __name__ == '__main__':
    csv_filename = sys.argv[1]
    template_filename = sys.argv[2]

    print_header()

    for row, template in csv_rows(csv_filename, template_filename):
        data = {}
        content_sql_traceset = row['Content SQL Trace Set (GitHub + BigQuery)']
        if content_sql_traceset.strip() == '':
            continue

        data['library'] = "'{0}'".format(row['Library'])
        data['languages'] = "'{0}'".format(row['Languages'])
        data['artifacts'] = row['Name in PM'].splitlines()
        data['imports_usages'] = row['Import or Usage'].split(',') if row['Import or Usage'] else []
        print(template.substitute(data))

    print_footer()