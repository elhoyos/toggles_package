SELECT DISTINCT r.name_with_owner, r.host_type, CAST(r.size * 1024 AS int64) AS bytes, r.language, r.fork_source_name_with_owner, r.updated_timestamp, libraries.artifact_name, libraries.library, libraries.languages AS library_language
FROM `bigquery-public-data.libraries_io.projects` p
INNER JOIN UNNEST([
$struct_libraries
]) libraries
ON p.name = libraries.artifact_name AND p.platform = libraries.platform
INNER JOIN `bigquery-public-data.libraries_io.repository_dependencies` rd
ON rd.dependency_project_id = p.id
INNER JOIN `bigquery-public-data.libraries_io.repositories` r
ON r.id = rd.repository_id