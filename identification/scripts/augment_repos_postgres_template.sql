WITH selected_projects AS (
  SELECT p.id, lower(concat(u.login, '/', p.name)) AS repo_name, lower(concat(uf.login, '/', f.name)) AS forked_from
  FROM projects p
  INNER JOIN users u ON u.id = p.owner_id
  LEFT JOIN projects f ON f.id = p.forked_from
  LEFT JOIN users uf ON uf.id = f.owner_id
  WHERE EXISTS (
    SELECT 1 FROM (VALUES
$values
    ) AS repos (repo_name)
    WHERE lower(repos.repo_name) = lower(concat(u.login, '/', p.name))
  )
)
SELECT p.id, repo_name, number_of_commits, last_commit_ts, forked_from, number_of_committers
FROM selected_projects p
INNER JOIN (
  SELECT project_id, sum(number_of_commits) AS number_of_commits, max(last_commit_ts) AS last_commit_ts, count(*) AS number_of_committers
  FROM (
    SELECT pc.project_id, co.author_id, count(*) AS number_of_commits, extract(epoch from max(co.created_at)) AS last_commit_ts
    FROM selected_projects p
    INNER JOIN project_commits pc ON pc.project_id = p.id
    INNER JOIN commits co ON co.id = pc.commit_id
    WHERE pc.project_id IN (SELECT id FROM selected_projects)
    GROUP BY pc.project_id, co.author_id
  )
  GROUP BY project_id
) c ON c.project_id = p.id