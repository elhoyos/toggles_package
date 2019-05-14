import sys
import csv
import pprint

# Takes the values of a multiple response column in a csv from a the survey results,
# splits it by semicolons and prints a new csv with the computed participation of
# each unique item.
#
# $ python print_multiple_responses_summary.py responses.csv "Why do you introduce feature toggles?"

if __name__ == "__main__":
    filepath = sys.argv[1]
    col_name = sys.argv[2]
    items = {}
    answers_count = 0

    with open(filepath, 'r') as csvfile:
        csv_reader = csv.DictReader(csvfile)

        for row in csv_reader:
            answers_count += 1
            value = row[col_name]
            keys = value.split(sep=";")
            for key in keys:
                item = items.get(key)
                if not item:
                    items[key] = {
                        'value': key,
                        'count': 1,
                    }
                else:
                    item['count'] += 1

    csv_writer = csv.DictWriter(sys.stdout, ('value', 'count', 'participation'))
    csv_writer.writeheader()
    for value in items.values():
        value['participation'] = value['count']/answers_count
        csv_writer.writerow(value)

    

