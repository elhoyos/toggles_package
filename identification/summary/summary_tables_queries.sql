with total_projects as (
	select count(*) as total from public.toggled_repositories
)
select
  library,
  replace(library_language, ',', ', ') as languages,
  count(*) as "# of projects",
  round(count(*)::decimal/(select total from total_projects) * 100, 2) as "% of projects"
from public.toggled_repositories
group by library, library_language
order by 3 desc;

with total_libraries as (
	select count(*) as total from libraries
)
select
  replace(languages, ',', ', ') as languages,
  count(*)::decimal/(select total from total_libraries) as "% of libraries",
  string_agg(name, ', ') as "libraries"
from libraries
group by languages
order by 2 desc;

select
  name || ' (' || replace(languages, ',', ', ') || ')',
  replace(package_manager_data, ',', ', '),
  replace(imports_or_usages, ',', ', ')
from libraries l
inner join (
  select library, library_language, count(*) as total_repositories
  from toggled_repositories
  group by library, library_language
) t
on t.library = l.name and t.library_language = l.languages
order by t.total_repositories desc, imports_or_usages asc
limit 10;