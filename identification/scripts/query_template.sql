SELECT toggled_projects.repo_name, toggled_projects.repo_data.path, toggled_projects.repo_data.language, toggled_projects.repo_data.size_bytes, $library AS library, $library_language AS library_language, last_commit_ts, forked_from FROM (
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
      WHERE $where_language_in
      AND $where_path_matches
    ) lang_files
    INNER JOIN `bigquery-public-data.github_repos.contents` contents ON contents.id = lang_files.id
    WHERE
    (
      $where_content_matches
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
