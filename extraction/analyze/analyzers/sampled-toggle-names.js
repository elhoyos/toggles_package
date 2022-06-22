const argv = require('minimist')(process.argv.slice(2));
const { resetCmd, execute } = require('../common');

/*
* Prints a csv with the toggle names at specific commits of a project using simple
* string searches.
*
* Useful to evaluate the recall of extractor.
*
* Usage:
* node sampled-toggle-names.js repo_name "commit_1,commit_2" "path/to/repository"
*/

const searchCmd = `
  pcregrep -Mor "(?:(?:flag_is_active|switch_is_active|sample_is_active|waffle_flag|waffle_switch)\([\"']?([\w.]+)[\"']?)|(?:{% switch|{% flag|{% sample)\s+[\"']?([\w.]+)[\"']?"
`


function searchToggles(pathToRepository, commit) {
  const command = [
    `(${resetCmd}) > /dev/null 2>&1`,
    `git checkout ${commit}`
    `${searchCmd} ${pathToRepository}`,
  ].join(' && ');

  return execute(command, pathToRepository)
    .then((stdout) => parseInt(stdout.trim(), 10));
}

async function collectToggles(repoName, commits, pathToRepository) {
  return commits.reduce(async (memo, commit) => {
    const toggles = await searchToggles(pathToRepository, commit);
    return [...memo, ...toggles.map((toggle) => ({
      repoName,
      commit,
      name: toggle.name,
    }))];
  }, []);
}

if (require.main === module) {
  (async () => {  
    const repoName = argv._[0];
    const commits = argv._[1].split(',');
    const pathToRepository = argv._[2];
    const toggles = await collectToggles(repoName, commits, pathToRepository);
    // TODO: print the file path
    console.log(Object.keys(toggles[0]).join(','));
    toggles.forEach((entry) => {
      console.log(Object.values(entry).join(','));
    });
  })();
}