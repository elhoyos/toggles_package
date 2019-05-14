const fs = require('fs');
const argv = require('minimist')(process.argv.slice(2));
const repo_name = argv._[0];
const json = fs.readFileSync(argv._[1]);
const pathToRepository = argv._[2];
const data = JSON.parse(json);
const { exec } = require('child_process');
const { resetCmd } = require('./common');

/*
* Prints a csv with the number of toggled commits, processed commits (as extractor does)
* and calculates the toggled effort rate.
*
* Usage:
* node rq1-commits.js repo_name history.json "path/to/repository"
*/

const uniqueCommits = new Map();

Object.keys(data).forEach((type) => {
  const toggles = data[type];
  Object.values(toggles).forEach((events) => {
    events.forEach((event) => {
      const commit = event.commit.commit;
      const parents = event.commit.parents;
      if (event.operation === 'CONTEXT_CHANGED') return;
      uniqueCommits.set(commit, { parents });
    });
  });
});

const firstToggledCommit = Array.from(uniqueCommits.keys())[0];
const withParents = !!uniqueCommits.get(firstToggledCommit).parents;
const command = [
  `(${resetCmd}) > /dev/null 2>&1`,

  // It is very important to do the same 'git log' as is done in the extractor
  // and that the history of commits is ordered from the oldest to the more
  // recent commit.

  // Check if parent exists to avoid 'unknown revision' errors when the first
  // toggled commit has no parents.
  `git log --pretty=format:'%H%n' --first-parent -m ${withParents ? `${firstToggledCommit}~1..HEAD` : ''} "*.py" "*.html" | wc -l`
].join(' && ');

exec(command, { cwd: pathToRepository }, (error, stdout, stderr) => {
  if (error || stderr) {
    if (stderr) error = new Error(stderr);
    throw error;
  }

  const toggledCommits = uniqueCommits.size;
  const processedCommits = parseInt(stdout.trim(), 10);
  const toggleEffort = toggledCommits/processedCommits;

  console.log('repo_name,toggled_commits,processed_comits,toggle_effort')
  console.log(`${repo_name},${toggledCommits},${processedCommits},${toggleEffort}`);
});
