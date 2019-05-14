# How good is GitHub BigQuery data?

Date: Dec 3rd, 2018

## Number of projects

```sql
-- 3352306
SELECT COUNT(*)
FROM `bigquery-public-data.github_repos.licenses`
```

```sql
-- 3351320
SELECT COUNT(*) FROM (
  SELECT 1
  FROM `bigquery-public-data.github_repos.files`
  GROUP BY repo_name
)
```

## Discovering projects

For example, using the togglz library:

> ...Togglz is incredibly popular. The Togglz core module was downloaded about 29k times from Maven Central last month. For me, that's quite impressive. I never expected Togglz to become so popular

https://groups.google.com/forum/#!topic/togglz-dev/4eL0tAO3q-A

All XML files using "togglz" in the code:

https://github.com/search?l=XML&q=togglz&type=Code

Projects (repositories) in GitHub depending on `org.togglz:togglz-core` (80, only 72 listed):

https://github.com/togglz/togglz/network/dependents?package_id=UGFja2FnZS0xODAxMDM2NjY%3D


### Verifying

https://github.com/ORCID/ORCID-Source is a desirable project not appearing in our "popular" projects list:

```sql
-- This query returned no results.
SELECT repo_name, count(*) AS num_of_files
FROM `bigquery-public-data.github_repos.files`
WHERE repo_name LIKE '%ORCID-Source%'
GROUP BY repo_name
```

```sql
-- Row	repo_name	          watch_count	
-- 1	  ORCID/ORCID-Source  9
SELECT *
FROM `bigquery-public-data.github_repos.sample_repos`
WHERE repo_name LIKE '%ORCID-Source%'
```

### Should not match

https://github.com/syndesisio/syndesis: This project [is using a library](https://github.com/syndesisio/syndesis/search?q=launchdarkly&unscoped_q=launchdarkly) from launchdarkly but not their toggles client library

### Wrong language

`erudit/zenon` redirects to `erudit/eruditorg`.

`erudit/zenon` is both in the contents and files tables.

`erudit/zenon` language is not correct. It shows up as Java, where its actually Python.


```sql
SELECT repo_name, language
FROM `bigquery-public-data.github_repos.languages`
WHERE repo_name IN ('erudit/zenon', 'erudit/eruditorg')
```

```json
[
  {
    "repo_name": "erudit/eruditorg",
    "language": [
      {
        "name": "CSS",
        "bytes": "164315"
      },
      {
        "name": "HTML",
        "bytes": "521648"
      },
      {
        "name": "JavaScript",
        "bytes": "53577"
      },
      {
        "name": "Makefile",
        "bytes": "909"
      },
      {
        "name": "Python",
        "bytes": "1365768"
      },
      {
        "name": "Shell",
        "bytes": "1323"
      },
      {
        "name": "TeX",
        "bytes": "1443"
      },
      {
        "name": "XSLT",
        "bytes": "88478"
      }
    ]
  },
  {
    "repo_name": "erudit/zenon",
    "language": [
      {
        "name": "CSS",
        "bytes": "106145"
      },
      {
        "name": "HTML",
        "bytes": "108060"
      },
      {
        "name": "Java",
        "bytes": "1554545"
      },
      {
        "name": "JavaScript",
        "bytes": "6561"
      },
      {
        "name": "Python",
        "bytes": "511247"
      },
      {
        "name": "XSLT",
        "bytes": "72079"
      }
    ]
  }
]
```
