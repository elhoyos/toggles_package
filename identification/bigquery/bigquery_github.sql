SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'launchdarkly' AS library, 'Objective-C,Swift' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Objective-C','Swift')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:m|h|swift)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'pod (?:`|\'|")LaunchDarkly(?:`|\'|")')
    OR REGEXP_CONTAINS(content, r'(?:#(import|include) "Darkly.h"|import LaunchDarkly)')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'launchdarkly' AS library, 'Kotlin,Java' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Kotlin','Java')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:gradle|gradle\.kts)$')
OR REGEXP_CONTAINS(path, r'(?i)\.java$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'compile.+launchdarkly-android-client')
    OR REGEXP_CONTAINS(content, r'import.+com\.launchdarkly\.android')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'toggle' AS library, 'Kotlin,Java' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Kotlin','Java')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:java|xml|gradle|gradle\.kts)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?i)(?:groupid>cc\.soham<\/groupid>\s+<artifactid>toggle<\/artifactid>|implementation \'cc\.soham:toggle:)')
    OR REGEXP_CONTAINS(content, r'import.+cc\.soham\.toggle')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'launchdarkly' AS library, 'Go' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Go')
      AND REGEXP_CONTAINS(path, r'(?i)\.go$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?i)"gopkg\.in\/launchdarkly\/go-client.*"')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'Toggle' AS library, 'Go' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Go')
      AND REGEXP_CONTAINS(path, r'(?i)\.go$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?i)"github.com\/xchapter7x\/toggle"')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'dcdr' AS library, 'Go' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Go')
      AND REGEXP_CONTAINS(path, r'(?i)\.go$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?i)"github.com\/vsco\/dcdr\/client"')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'unleash-client-go' AS library, 'Go' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Go')
      AND REGEXP_CONTAINS(path, r'(?i)\.go$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?i)"github.com\/Unleash\/unleash-client-go"')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'unleash-client-java' AS library, 'Kotlin,Java' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Kotlin','Java')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:java|xml|gradle|gradle\.kts)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?i)(?:groupid>no\.finn\.unleash<\/groupid>\s+<artifactid>unleash-client-java<\/artifactid>|compile.+no\.finn\.unleash)')
    OR REGEXP_CONTAINS(content, r'import no\.finn\.unleash')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'unleash-client-node' AS library, 'JavaScript,TypeScript' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('JavaScript','TypeScript')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:json|js|jsx|ts|tsx)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.json$') AND REGEXP_CONTAINS(content, r'(?:devDependencies|dependencies)":\s*{(?:\s|.)*?"unleash-client"'))
    OR (REGEXP_CONTAINS(path, r'(?i)\.(?:js|jsx|ts|tsx)$') AND REGEXP_CONTAINS(content, r'(?:require.+|import.+|from.+)(?:"|\')unleash-client(?:"|\')'))
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'unleash-client-ruby' AS library, 'Ruby' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Ruby')
      AND REGEXP_CONTAINS(path, r'(?i)(?:\.rb|Gemfile)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?:require|gem) (?:"|\')unleash(?:"|\')')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'unleash-client-dotnet' AS library, 'C#,Visual Basic' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('C#','Visual Basic')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:cs|json|config|csproj|vbproj)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.(?:config|csproj|vbproj)$') AND REGEXP_CONTAINS(content, r'(?i)(?:<package\s*id=|<PackageReference\s*Include=|<Reference\s*Include=)"Unleash.FeatureToggle.Client'))
    OR (REGEXP_CONTAINS(path, r'(?i)\.json$') AND REGEXP_CONTAINS(content, r'dependencies":\s*{(?:\s|.)*?"Unleash.FeatureToggle.Client'))
    OR (REGEXP_CONTAINS(path, r'(?i)\.cs$') AND REGEXP_CONTAINS(content, r'(?i)using.+Unleash'))
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'unleash-client' AS library, 'C#,Visual Basic' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('C#','Visual Basic')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:json|config|csproj|vbproj)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.(?:config|csproj|vbproj)$') AND REGEXP_CONTAINS(content, r'(?i)(?:<package\s*id=|<PackageReference\s*Include=|<Reference\s*Include=)"unleash.client'))
    OR (REGEXP_CONTAINS(path, r'(?i)\.json$') AND REGEXP_CONTAINS(content, r'dependencies":\s*{(?:\s|.)*?"unleash.client'))
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'unleash-client-python' AS library, 'Python' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Python')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:txt|py)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.txt$') AND REGEXP_CONTAINS(content, r'(?m)^UnleashClient(?:\[|\s+|~|=|>|<|!|"|\')'))
    OR REGEXP_CONTAINS(content, r'(?i)install_requires=(?:\s|.)*?(?:"|\')UnleashClient(?:\[|\s+|~|=|>|<|!|"|\')')
    OR REGEXP_CONTAINS(content, r'(?:import|from).+UnleashClient')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'launchdarkly' AS library, 'Kotlin,Java' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Kotlin','Java')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:java|xml|gradle|gradle\.kts)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?i)(?:groupid>com\.launchdarkly<\/groupid>\s+<artifactid>launchdarkly-client<\/artifactid>|compile.+launchdarkly-client)')
    OR REGEXP_CONTAINS(content, r'import.+com\.launchdarkly\.client')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'Togglz' AS library, 'Kotlin,Java' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Kotlin','Java')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:java|xml|gradle|gradle\.kts)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?i)(?:groupid>org\.togglz<\/groupid>\s+<artifactid>togglz-(core|servlet|cdi|spring-web|spring-boot-starter|jsf)<\/artifactid>|compile.+togglz-(core|spring-boot-starter|console|spring-security))')
    OR REGEXP_CONTAINS(content, r'import.+org\.togglz\.core')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'FF4J' AS library, 'Kotlin,Java' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Kotlin','Java')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:java|xml)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?i)(?:groupid>org\.ff4j<\/groupid>\s+<artifactid>ff4j-(core|web)<\/artifactid>)')
    OR REGEXP_CONTAINS(content, r'import org\.ff4j')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'Flip' AS library, 'Kotlin,Java' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Kotlin','Java')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:xml|gradle|gradle\.kts)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?i)(?:groupid>com\.tacitknowledge\.flip<\/groupid>\s+<artifactid>(core|servlet|spring)<\/artifactid>|compile.+com\.tacitknowledge\.flip:(core|servlet|spring))')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'launchdarkly' AS library, 'JavaScript,TypeScript' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('JavaScript','TypeScript')
      AND REGEXP_CONTAINS(path, r'(?i)\.html$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?i)<script.+src=.*?snippet/ldclient.min.js')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'ember-feature-flags' AS library, 'JavaScript,TypeScript' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('JavaScript','TypeScript')
      AND REGEXP_CONTAINS(path, r'(?i)\.json$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.json$') AND REGEXP_CONTAINS(content, r'(?:devDependencies|dependencies)":\s*{(?:\s|.)*?("|\')ember-feature-flags("|\')'))
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'feature-toggles' AS library, 'JavaScript,TypeScript' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('JavaScript','TypeScript')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:json|js|jsx|ts|tsx)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.json$') AND REGEXP_CONTAINS(content, r'(?:devDependencies|dependencies)":\s*{(?:\s|.)*?("|\')feature-toggles("|\')'))
    OR (REGEXP_CONTAINS(path, r'(?i)\.(?:js|jsx|ts|tsx)$') AND REGEXP_CONTAINS(content, r'(?:require.+|import.+|from.+)(?:"|\')feature-toggles(?:"|\')'))
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'React Feature Toggles' AS library, 'JavaScript,TypeScript' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('JavaScript','TypeScript')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:json|js|jsx|ts|tsx)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.json$') AND REGEXP_CONTAINS(content, r'(?:devDependencies|dependencies)":\s*{(?:\s|.)*?("|\')@paralleldrive\/react-feature-toggles("|\')'))
    OR (REGEXP_CONTAINS(path, r'(?i)\.(?:js|jsx|ts|tsx)$') AND REGEXP_CONTAINS(content, r'(?:require.+|import.+|from.+)(?:"|\')@paralleldrive\/react-feature-toggles(?:"|\')'))
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'launchdarkly' AS library, 'C#,Visual Basic' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('C#','Visual Basic')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:cs|json|config|csproj|vbproj)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.(?:config|csproj|vbproj)$') AND REGEXP_CONTAINS(content, r'(?i)(?:<package\s*id=|<PackageReference\s*Include=|<Reference\s*Include=)"LaunchDarkly.Client'))
    OR (REGEXP_CONTAINS(path, r'(?i)\.json$') AND REGEXP_CONTAINS(content, r'dependencies":\s*{(?:\s|.)*?"LaunchDarkly.Client'))
    OR (REGEXP_CONTAINS(path, r'(?i)\.cs$') AND REGEXP_CONTAINS(content, r'(?i)using LaunchDarkly\.Client'))
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'NFeature' AS library, 'C#,Visual Basic' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('C#','Visual Basic')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:json|config|csproj|vbproj)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.(?:config|csproj|vbproj)$') AND REGEXP_CONTAINS(content, r'(?i)(?:<package\s*id=|<PackageReference\s*Include=|<Reference\s*Include=)"NFeature'))
    OR (REGEXP_CONTAINS(path, r'(?i)\.json$') AND REGEXP_CONTAINS(content, r'dependencies":\s*{(?:\s|.)*?"NFeature'))
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'FeatureToggle' AS library, 'C#,Visual Basic' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('C#','Visual Basic')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:json|config|csproj|vbproj)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.(?:config|csproj|vbproj)$') AND REGEXP_CONTAINS(content, r'(?i)(?:<package\s*id=|<PackageReference\s*Include=|<Reference\s*Include=)"FeatureToggle'))
    OR (REGEXP_CONTAINS(path, r'(?i)\.json$') AND REGEXP_CONTAINS(content, r'dependencies":\s*{(?:\s|.)*?"FeatureToggle'))
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'FeatureSwitcher' AS library, 'C#,Visual Basic' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('C#','Visual Basic')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:json|config|csproj|vbproj)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.(?:config|csproj|vbproj)$') AND REGEXP_CONTAINS(content, r'(?i)(?:<package\s*id=|<PackageReference\s*Include=|<Reference\s*Include=)"FeatureSwitcher'))
    OR (REGEXP_CONTAINS(path, r'(?i)\.json$') AND REGEXP_CONTAINS(content, r'dependencies":\s*{(?:\s|.)*?"FeatureSwitcher'))
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'nToggle' AS library, 'C#,Visual Basic' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('C#','Visual Basic')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:json|config|csproj|vbproj)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.(?:config|csproj|vbproj)$') AND REGEXP_CONTAINS(content, r'(?i)(?:<package\s*id=|<PackageReference\s*Include=|<Reference\s*Include=)"nToggle'))
    OR (REGEXP_CONTAINS(path, r'(?i)\.json$') AND REGEXP_CONTAINS(content, r'dependencies":\s*{(?:\s|.)*?"nToggle'))
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'Toggler' AS library, 'C#,Visual Basic' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('C#','Visual Basic')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:json|config|csproj|vbproj)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.(?:config|csproj|vbproj)$') AND REGEXP_CONTAINS(content, r'(?i)(?:<package\s*id=|<PackageReference\s*Include=|<Reference\s*Include=)"Toggler'))
    OR (REGEXP_CONTAINS(path, r'(?i)\.json$') AND REGEXP_CONTAINS(content, r'dependencies":\s*{(?:\s|.)*?"Toggler'))
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'launchdarkly' AS library, 'JavaScript,TypeScript' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('JavaScript','TypeScript')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:json|js|jsx|ts|tsx)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.json$') AND REGEXP_CONTAINS(content, r'(?:devDependencies|dependencies)":\s*{(?:\s|.)*?"ldclient-node"'))
    OR (REGEXP_CONTAINS(path, r'(?i)\.(?:js|jsx|ts|tsx)$') AND REGEXP_CONTAINS(content, r'(?:require.+|import.+|from.+)(?:"|\')ldclient-node(?:"|\')'))
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'flipit' AS library, 'JavaScript,TypeScript' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('JavaScript','TypeScript')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:json|js|jsx|ts|tsx)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.json$') AND REGEXP_CONTAINS(content, r'(?:devDependencies|dependencies)":\s*{(?:\s|.)*?"flipit"'))
    OR (REGEXP_CONTAINS(path, r'(?i)\.(?:js|jsx|ts|tsx)$') AND REGEXP_CONTAINS(content, r'(?:require.+|import.+|from.+)(?:"|\')flipit(?:"|\')'))
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'fflip' AS library, 'JavaScript,TypeScript' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('JavaScript','TypeScript')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:json|js|jsx|ts|tsx)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.json$') AND REGEXP_CONTAINS(content, r'(?:devDependencies|dependencies)":\s*{(?:\s|.)*?"fflip"'))
    OR (REGEXP_CONTAINS(path, r'(?i)\.(?:js|jsx|ts|tsx)$') AND REGEXP_CONTAINS(content, r'(?:require.+|import.+|from.+)(?:"|\')fflip(?:"|\')'))
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'launchdarkly' AS library, 'PHP' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('PHP')
      AND REGEXP_CONTAINS(path, r'(?i)\.?:(json|php)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?i)require":\s*{(?:\s|.)*?"launchdarkly\/launchdarkly-php"')
    OR REGEXP_CONTAINS(content, r'(?i)LaunchDarkly\\LDClient')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'Symfony FeatureFlagsBundle' AS library, 'PHP' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('PHP')
      AND REGEXP_CONTAINS(path, r'(?i)\.?:(json|php)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?i)require":\s*{(?:\s|.)*?"dzunke\/feature-flags-bundle"')
    OR REGEXP_CONTAINS(content, r'(?i)DZunke\\FeatureFlagsBundle\\DZunkeFeatureFlagsBundle')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'Toggle' AS library, 'PHP' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('PHP')
      AND REGEXP_CONTAINS(path, r'(?i)\.?:(json|php)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?i)require":\s*{(?:\s|.)*?"qandidate\/toggle"')
    OR REGEXP_CONTAINS(content, r'(?i)Qandidate\\Toggle')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'rollout' AS library, 'PHP' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('PHP')
      AND REGEXP_CONTAINS(path, r'(?i)\.?:(json|php)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?i)require":\s*{(?:\s|.)*?"opensoft\/rollout"')
    OR REGEXP_CONTAINS(content, r'(?i)Opensoft\\Rollout')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'launchdarkly' AS library, 'Python' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Python')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:txt|py)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.txt$') AND REGEXP_CONTAINS(content, r'(?m)^ldclient-py(?:\[|\s+|~|=|>|<|!|"|\')'))
    OR REGEXP_CONTAINS(content, r'(?i)install_requires=(?:\s|.)*?(?:"|\')ldclient-py(?:\[|\s+|~|=|>|<|!|"|\')')
    OR REGEXP_CONTAINS(content, r'(?:import|from).+ldclient')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'Flask FeatureFlags' AS library, 'Python' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Python')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:txt|py)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.txt$') AND REGEXP_CONTAINS(content, r'(?m)^Flask-FeatureFlags(?:\[|\s+|~|=|>|<|!|"|\')'))
    OR REGEXP_CONTAINS(content, r'(?i)install_requires=(?:\s|.)*?(?:"|\')Flask-FeatureFlags(?:\[|\s+|~|=|>|<|!|"|\')')
    OR REGEXP_CONTAINS(content, r'(?:import|from).+flask_featureflags')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'Gutter' AS library, 'Python' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Python')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:txt|py)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.txt$') AND REGEXP_CONTAINS(content, r'(?m)^gutter(?:\[|\s+|~|=|>|<|!|"|\')'))
    OR REGEXP_CONTAINS(content, r'(?i)install_requires=(?:\s|.)*?(?:"|\')gutter(?:\[|\s+|~|=|>|<|!|"|\')')
    OR REGEXP_CONTAINS(content, r'(?:import|from).+gutter\.client')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'Feature Ramp' AS library, 'Python' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Python')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:txt|py)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.txt$') AND REGEXP_CONTAINS(content, r'(?m)^feature_ramp(?:\[|\s+|~|=|>|<|!|"|\')'))
    OR REGEXP_CONTAINS(content, r'(?i)install_requires=(?:\s|.)*?(?:"|\')feature_ramp(?:\[|\s+|~|=|>|<|!|"|\')')
    OR REGEXP_CONTAINS(content, r'(?:import|from).+feature_ramp\.Feature')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'flagon' AS library, 'Python' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Python')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:txt|py)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.txt$') AND REGEXP_CONTAINS(content, r'(?m)^flagon(?:\[|\s+|~|=|>|<|!|"|\')'))
    OR REGEXP_CONTAINS(content, r'(?i)install_requires=(?:\s|.)*?(?:"|\')flagon(?:\[|\s+|~|=|>|<|!|"|\')')
    OR REGEXP_CONTAINS(content, r'(?:import|from).+flagon\.feature')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'launchdarkly' AS library, 'Ruby' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Ruby')
      AND REGEXP_CONTAINS(path, r'(?i)(?:\.rb|Gemfile)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?:require|gem) (?:"|\')ldclient-rb(?:"|\')')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'rollout' AS library, 'Ruby' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Ruby')
      AND REGEXP_CONTAINS(path, r'(?i)(?:\.rb|Gemfile)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?:require|gem) (?:"|\')rollout(?:"|\')')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'FeatureFlipper' AS library, 'Ruby' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Ruby')
      AND REGEXP_CONTAINS(path, r'(?i)(?:\.rb|Gemfile)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?:require|gem) (?:"|\')feature_flipper(?:"|\')')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'Flip' AS library, 'Ruby' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Ruby')
      AND REGEXP_CONTAINS(path, r'(?i)(?:\.rb|Gemfile)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?:require|gem) (?:"|\')flip(?:"|\')')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'Setler' AS library, 'Ruby' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Ruby')
      AND REGEXP_CONTAINS(path, r'(?i)(?:\.rb|Gemfile)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?:require|gem) (?:"|\')setler(?:"|\')')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'Bandiera' AS library, 'Ruby' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Ruby')
      AND REGEXP_CONTAINS(path, r'(?i)(?:\.rb|Gemfile)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'gem (?:"|\')bandiera-client(?:"|\')')
    OR REGEXP_CONTAINS(content, r'require (?:"|\')bandiera\/client(?:"|\')')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'Bandiera' AS library, 'JavaScript,TypeScript' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('JavaScript','TypeScript')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:json|js|jsx|ts|tsx)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.json$') AND REGEXP_CONTAINS(content, r'(?:devDependencies|dependencies)":\s*{(?:\s|.)*?"bandiera-client"'))
    OR (REGEXP_CONTAINS(path, r'(?i)\.(?:js|jsx|ts|tsx)$') AND REGEXP_CONTAINS(content, r'(?:require.+|import.+|from.+)(?:"|\')bandiera-client(?:"|\')'))
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'Bandiera' AS library, 'PHP' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('PHP')
      AND REGEXP_CONTAINS(path, r'(?i)\.?:(json|php)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?i)require":\s*{(?:\s|.)*?"npg\/bandiera-client-php"')
    OR REGEXP_CONTAINS(content, r'(?i)Nature\\Bandiera\\Client')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'Bandiera' AS library, 'Scala' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Scala')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:sbt|scala|sc)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?i)bandiera-client-scala')
    OR REGEXP_CONTAINS(content, r'import.+com\.springernature\.bandieraclientscala')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'Feature' AS library, 'Ruby' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Ruby')
      AND REGEXP_CONTAINS(path, r'(?i)(?:\.rb|Gemfile)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?:require|gem) (?:"|\')feature(?:"|\')')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'Waffle' AS library, 'Python' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Python')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:txt|py)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.txt$') AND REGEXP_CONTAINS(content, r'(?m)^django-waffle(?:\[|\s+|~|=|>|<|!|"|\')'))
    OR REGEXP_CONTAINS(content, r'(?i)install_requires=(?:\s|.)*?(?:"|\')django-waffle(?:\[|\s+|~|=|>|<|!|"|\')')
    OR REGEXP_CONTAINS(content, r'(?:(?:import|from).+waffle|(?:INSTALLED_APPS|THIRD_PARTY_APPS|MIDDLEWARE_CLASSES).+(?:"|\')waffle.*)')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'flopflip' AS library, 'JavaScript,TypeScript' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('JavaScript','TypeScript')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:json|js|jsx|ts|tsx)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.json$') AND REGEXP_CONTAINS(content, r'(?:devDependencies|dependencies)":\s*{(?:\s|.)*?"(?:@flopflip\/react-redux|@flopflip\/react-broadcast)"'))
    OR (REGEXP_CONTAINS(path, r'(?i)\.(?:js|jsx|ts|tsx)$') AND REGEXP_CONTAINS(content, r'(?:require.+|import.+|from.+)(?:"|\')(?:@flopflip\/react-redux|@flopflip\/react-broadcast)(?:"|\')'))
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'Gargoyle' AS library, 'Python' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Python')
      AND REGEXP_CONTAINS(path, r'(?i)\.(?:txt|py)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      (REGEXP_CONTAINS(path, r'(?i)\.txt$') AND REGEXP_CONTAINS(content, r'(?m)^(?:gargoyle|gargoyle-yplan)(?:\[|\s+|~|=|>|<|!|"|\')'))
    OR REGEXP_CONTAINS(content, r'(?:(?:import|from).+gargoyle|(?:INSTALLED_APPS|THIRD_PARTY_APPS|MIDDLEWARE_CLASSES).+(?:"|\')gargoyle.*)')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, 'Flipper' AS library, 'Ruby' AS library_language, last_commit_ts, forked_from FROM (
  SELECT repo_name, ARRAY_AGG(STRUCT<path string, language string, size_bytes int64>(path, language, size_bytes) LIMIT 1)[OFFSET(0)] repo_data FROM (
    SELECT lang_files.* FROM (
      SELECT files.id, files.repo_name, files.path, langs.language, size.bytes AS size_bytes
      FROM `bigquery-public-data.github_repos.files` files
      INNER JOIN (
        SELECT repo_name, lang.name AS language
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        INNER JOIN UNNEST(['C#', 'Visual Basic', 'Java', 'Kotlin', 'JavaScript', 'TypeScript', 'Objective-C', 'Swift', 'PHP', 'Python', 'Ruby', 'Scala', 'Go']) AS supported_langs
        ON lang.name = supported_langs
      ) langs
      ON langs.repo_name = files.repo_name
      INNER JOIN (
        SELECT repo_name, SUM(lang.bytes) AS bytes
        FROM `bigquery-public-data.github_repos.languages`, UNNEST(language) lang
        GROUP BY repo_name
      ) size
      ON size.repo_name = files.repo_name
      WHERE language IN('Ruby')
      AND REGEXP_CONTAINS(path, r'(?i)(?:\.rb|Gemfile)$')
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      REGEXP_CONTAINS(content, r'(?:require|gem) (?:"|\')flipper(?:"|\')')
    )
  )
  GROUP BY repo_name
) toggled_projects
INNER JOIN (
  SELECT repo AS repo_name, COUNT(commit) AS number_of_commits, MAX(author.time_sec) AS last_commit_ts
  FROM `bigquery-public-data.github_repos.commits` c, UNNEST(repo_name) AS repo
  GROUP BY 1
) last_commits
ON last_commits.repo_name = toggled_projects.repo_name
LEFT JOIN (
  SELECT REPLACE(p1.url, 'https://api.github.com/repos/', '') AS repo_name, REPLACE(p2.url, 'https://api.github.com/repos/', '') as forked_from
  FROM `ghtorrent-bq.ght_2018_04_01.projects` p1
  INNER JOIN `ghtorrent-bq.ght_2018_04_01.projects` p2
  ON p1.forked_from = p2.id
) projects
ON projects.repo_name = toggled_projects.repo_name

UNION ALL

