# identification

Procedures and results of identified toggled repositories.

## Usage

The compilation of all the trace sets is located in `trace-sets.csv`. These trace sets were mirrored into the tools used in the Libraries.io and githubdisco sections to identify toggled repositories.

### Libraries.io

Run `biquery/bigquery_librariesio.sql` against Google BigQuery or against your own copy of Libraries.io database to identify repositories using toggles libraries as dependencies.

### githubdisco

First, install [githubdisco@fd94b42](https://github.com/elhoyos/githubdisco/tree/fd94b42ff19a196514c8def7a45332c251916d69) from its repository following its usage instructions.

Next, identify repositories in GitHub using the libraries registered in `libraries.py` by running

```bash
$ scrapy crawl toggled_repos -o toggled_repos_github.csv
```

### Augmenting repositories data

Once you have toggled repositories from Libraries.io and GitHub, you can merge them using the following command:

```bash
$ sh merge-results.sh {toggled_repos_librariesio,toggled_repos_github}.csv > toggled_repositories.csv
```

And then, augment the information of the identified toggled repositories, using

```bash
$ scrapy crawl augment_toggled_repos -a repos_filename=toggled_repositories.csv -o toggled_repositories_augmented.csv
```

### Filtering useful repositories

Finally, keep the relevant toggled repositories using the following command:

```bash
cat toggled_repositories_augmented.csv | python filter_results.py trace-sets.csv --extrafilters > toggled_repos_filtered.csv
```

## Results

After decompressing `results.tar.gz`, you can locate the identified toggled repositories and the raw data at intermediary steps.

In our exercise, we augmented and filtered the results of each source separately to analyze the overlap across sources. The final filtered toggled repositories list is contained in `results/filtered_results.xlsx`.

### Summary tables

We also loaded the trace sets and the identified toggled repositories into a database to aggregate the data and obtain useful information.

You can create some summary tables in a `toggles` PostgreSQL with the following commands:

```bash
$ createdb toggles
$ psql toggles -f summary/summary_tables.sql
```

Checkout the queries in `summary_tables_queries.sql`.

### More summaries

Checkout the R scripts located in this package to get more information regarding the toggled libraries and repositories.
