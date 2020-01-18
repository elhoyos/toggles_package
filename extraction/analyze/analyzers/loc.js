const fs = require('fs');
const argv = require('minimist')(process.argv.slice(2));
const repo_name = argv._[0];
const json = fs.readFileSync(argv._[1]);
const pathToRepository = argv._[2];
const data = JSON.parse(json);
const { exec } = require('child_process');
const { resetCmd } = require('../common');

/*
* Prints a csv with the toggled loc vs Python loc of the project
*
* Usage:
* node loc.js repo_name history.json "path/to/repository"
*/

const locTypeComponent = {
  'Router': {},
  'Point': {},
};

// Get the max loc per toggle component
Object.keys(data).forEach((type) => {
  const componentsEvents = data[type];
  Object.keys(componentsEvents).forEach((componentId) => {
    locTypeComponent[type][componentId] = -1;
    const events = componentsEvents[componentId];
    events.forEach((event) => {
      const { start, end } = event.toggle;
      const loc = end.line - start.line + 1;
      if (locTypeComponent[type][componentId] < loc) {
        locTypeComponent[type][componentId] = loc;
      }
    });
  });
});

// Group by type of component
const locType = {
  'Router': 0,
  'Point': 0,
};
Object.keys(locTypeComponent).forEach((type) => {
  const locComponent = locTypeComponent[type];
  locType[type] = Object.keys(locComponent).reduce((memo, componentId) => {
    return memo + locComponent[componentId];
  }, 0);
});

const command = [
  `(${resetCmd}) > /dev/null 2>&1`,
  'cloc --quiet --include-lang=Python,HTML --json .',
].join(' && ');

exec(command, { cwd: pathToRepository }, (error, stdout, stderr) => {
  if (error || stderr) {
    if (stderr) error = new Error(stderr);
    throw error;
  }

  // TODO: use also the Router. If do not intersect, count.
  const toggledLOC = locType['Point'];
  const projectLOC = JSON.parse(stdout)['SUM'].code;
  const coverage = toggledLOC/projectLOC;

  console.log('repo_name,toggled_loc,project_loc,coverage');
  console.log(`${repo_name},${toggledLOC},${projectLOC},${coverage}`);
});


