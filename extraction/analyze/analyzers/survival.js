const fs = require('fs');
const argv = require('minimist')(process.argv.slice(2));
const repo_name = argv._[0];
const json = fs.readFileSync(argv._[1]);
const pathToRepository = argv._[2];
const data = JSON.parse(json);
const { exec } = require('child_process');
const { resetCmd } = require('../common');

/*
* Prints a csv appropriate for a survival analysis of a projects's history
*
* Usage:
* node survival.js repo_name history.json "path/to/repository"
*/

function getLastEpoch(callback) {
  const command = [
    `(${resetCmd}) > /dev/null 2>&1`,
    `git log --pretty=format:%ct -n1`
  ].join(' && ');

  exec(command, { cwd: pathToRepository }, (error, stdout, stderr) => {
    if (error || stderr) {
      if (stderr) error = new Error(stderr);
      callback(error);
    }

    callback(null, parseInt(stdout.trim(), 10));
  });
}

getLastEpoch((err, lastEpoch) => {
  if (err) throw err;

  const survival = [];

  Object.keys(data).forEach((type) => {
    const toggles = data[type];
    Object.keys(toggles).forEach((toggleId) => {
      const events = toggles[toggleId];
      const firstEvent = events[0];
      const lastEvent = events[events.length - 1];
      const t1 = parseInt(firstEvent.commit.committerTs, 10);
      const t2 = lastEvent.operation === 'DELETED' ? parseInt(lastEvent.commit.committerTs, 10) : lastEpoch;
      survival.push({
        repo_name,
        toggle_id: toggleId,
        toggle_type: firstEvent.toggle.type,
        epoch_interval: t2 - t1,
        removed: (lastEvent.operation === 'DELETED' ? 1 : 0),
      });
    });
  });

  console.log(Object.keys(survival[0]).join(','));
  survival.forEach((entry) => {
    console.log(Object.values(entry).join(','));
  });
});
