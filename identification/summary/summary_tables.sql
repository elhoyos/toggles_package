create table toggled_repositories
(
	repo_name text not null
		constraint toggled_repositories_pkey
			primary key,
	library text not null,
	library_language text not null,
	number_of_commits bigint not null
);

create table libraries
(
	name text not null,
	languages text not null,
	package_manager_data text,
	imports_or_usages text,
	repositories text not null
);

\copy toggled_repositories(repo_name, library, library_language, number_of_commits) FROM 'summary_tables_toggled_repositories.csv' CSV HEADER

\copy libraries(name, languages, package_manager_data, imports_or_usages, repositories) FROM 'summary_tables_trace_sets.csv' CSV HEADER
