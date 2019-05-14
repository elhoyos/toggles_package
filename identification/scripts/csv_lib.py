import csv
import string

# Yields { row<Dict>, template<string.Template> } from a csv
def csv_rows(csv_filename, template_filename):
  with open(template_filename, 'r') as template_file:
    template = string.Template(template_file.read())

  with open(csv_filename, 'r') as csv_file:
    csv_reader = csv.DictReader(csv_file)

    for row in csv_reader:
      yield row, template

# Yields line<String>, i<Number>, row<Dict> when reading a csv form
# stdin
def parse_csv_line(stdin, fieldnames=None):
    i = 0
    for line in stdin:
        i += 1
        if i == 1:
            fieldnames = line.strip().split(',') if not fieldnames else fieldnames
            yield line, i, {}
            continue

        reader = csv.DictReader([line], fieldnames=fieldnames)
        for row in reader:
            yield line, i, row