import sys
import csv
import re
from csv_lib import parse_csv_line
import argparse

# Takes a csv of matched repositories results and prints
# the same csv without duplicated nor toggling libraries entries.
#
# A trace-sets.csv is also required to extract the toggling libraries
# repo names. Only GitHub is supported.
#
# The csv *must* contain a header in the first line.
#
# The first entry found across deduplicated ones will be used.
#
# Extra filters can be enabled using the --extrafilters flag
#
# Usage:
# $ cat results/raw/results-*.csv | python filter_results.py trace-sets.csv --extrafilters > results/filtered_results.csv

banned_repo_names_regexps = [
    # Collections of repositories via dependencies
    r'.+\/DefinitelyTyped',
    r'.+\/AngularTypings',
    r'.+\/repos-using-electron',
    r'Jacek1993/tutorial',
    r'raser004/Tutorials',
    r'DevJoseWeb/Java-Diversos',
    r'ntthuat/HelloSpring',
    r'nguyenhaidhcn/java-tutorial',
    r'my-branding-repo/tutorials-master',
    r'spring-open-source/projects',
    r'hasitha3rd/spring-rest-security',
    r'sjkendall88/GitHub',
    r'jhavierc/spring',
    r'phuongchuyentin/spring-master',
    r'naitae99/tutorials',
    r'a08maheshwari/MVC',
    r'srilakshmichennu/mypipelinecode',
    r'mksoni29/6sept',
    r'cuidadoso/tuturials',
    r'debjava/baeldungGIT',
    r'chaakula/SpringPractice',
    r'samarthsaxena/AllJavaTutorials',
    r'vejandlakrishna/Tutorials',
    r'itskautuk/tutorials',
    r'lvt100191/spring_tutorial',
    r'ashablj/spring-5',
    r'luc-neulens/test',
    r'retana/Tutoriales',
    r'nishantverma160380/Spring-Security',
    r'nishantverma160380/Spring-Cloud-Tutorial',
    r'vinodkuliza/demo-pipeline2',
    r'deepakpanda1/tutorials',
    r'nangudeprashant/SpringMVC',
    r'ngonzalez1981/tutorial',
    r'nkadiri09/Spring_all',
    r'nishantverma160380/aws-tutorials',
    r'vermaabhishek19801/Eugenp_Tutorials',
    r'chandansinghkiit/Spring_Webservice',
    r'TehreemNisa/tutorials',
    r'Java-Reference/Java_Practices',
    r'GitHubRaju/https-github.com-eugenp-tutorials',
    r'Vijaydaswani/Jenkins',
    r'eugenp/tutorials',
    r'pcf2cloud/Tutorial',
]

def matches_any(patterns, string):
    matches = False
    for regexp in patterns:
        matches = bool(re.match(regexp, string, re.IGNORECASE))
        if matches:
            return matches
    return matches

def is_banned(result):
    banned = matches_any(banned_repo_names_regexps, result['repo_name'])
    return banned

min_bytes = 1000 * 1000
def has_not_enough_size(result):
    bytes = result['size_bytes']
    return not bytes or int(bytes) < min_bytes

min_commits = 100
def has_not_enough_commits(result):
    commits = result['number_of_commits']
    return not commits or int(commits) < min_commits

def is_not_accessible(result):
    return bool(result['repo_not_found'])

def is_a_fork(result):
    return bool(result['forked_from'])

repos_by_first_commit = {}
# Not really a filter, but useful to gather data to remove clones
def build_repos_by_first_commit(result):
    clones = repos_by_first_commit.get(result['first_commit_sha'])
    if not clones:
        repos_by_first_commit[result['first_commit_sha']] = [result]
    else:
        clones.append(result)
    return False

earliest_repos = {}
def remove_clones(parsed_lines):
    for line, i, row in parsed_lines:
        if i == 1:
            continue

        clones = repos_by_first_commit.get(row['first_commit_sha'])

        if not clones:
            continue

        earliest = row
        for clone in clones:
            if earliest['created_at'] > clone['created_at']:
                earliest = clone

        # Remove the list to bypass parsed lines without clones
        repos_by_first_commit[row['first_commit_sha']] = None
        earliest_repos[earliest['repo_name']] = earliest

    # Efficiently mutate the parsed lines list and go easier with
    # the memory usage.
    # https://stackoverflow.com/a/1208792/638425
    parsed_lines[:] = [(line, i, row) for line, i, row in parsed_lines if i == 1 or earliest_repos.get(row['repo_name'])]
    return parsed_lines

extra_filters = [
    is_banned,
    has_not_enough_commits,
    is_not_accessible,
    is_a_fork,

    # Not actually a filter
    build_repos_by_first_commit,
]

repositories = {}
def is_duplicated(result):
    repo_name = result['repo_name'].lower()
    duplicated = True if repositories.get(repo_name) else False
    repositories[repo_name] = True
    return duplicated

toggling_libraries = set()
def is_toggling_library(result):
    if not bool(toggling_libraries):
        toggling_libraries.update(load_toggling_libraries())

    return True if result['repo_name'].lower() in toggling_libraries else False

def load_toggling_libraries():
    tracesets_filename = sys.argv[1]
    with open(tracesets_filename, 'r') as tracesets:
        reader = csv.DictReader(tracesets)
        libraries = set()
        for row in reader:
            togglinglibs = row['Repositories']
            for library in togglinglibs.strip().splitlines():
                libraries.add(library.replace('https://github.com/', '').lower())

        return libraries

def print(line):
    sys.stdout.write(line)
    sys.stdout.flush()

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('tracesets_csv', help='csv containing the library names')
    parser.add_argument("--extrafilters", help="process the csv with extra filters", action="store_true")
    args = parser.parse_args()

    lines = []
    for line, i, row in parse_csv_line(sys.stdin):
        if i == 1:
            lines.append((line, i, row))
            continue

        if is_duplicated(row):
            continue

        if is_toggling_library(row):
            continue

        if args.extrafilters:
            remove = False
            for filter in extra_filters:
                remove = filter(row)
                if remove:
                    break

            if remove:
                continue

        lines.append((line, i, row))

    if args.extrafilters:
        lines = remove_clones(lines)

    for parsed_line in lines:
        print(parsed_line[0])