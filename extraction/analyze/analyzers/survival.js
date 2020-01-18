const fs = require('fs');
const argv = require('minimist')(process.argv.slice(2));
const { exec } = require('child_process');
const { resetCmd } = require('../common');

/*
* Prints a csv appropriate for a survival analysis of a projects's history
*
* Usage:
* node survival.js repo_name history.json "path/to/repository"
*/

function execute(command, cwd) {
  return new Promise((resolve, reject) => {
    exec(command, { cwd }, (error, stdout, stderr) => {
      if (error || stderr) {
        if (stderr) error = new Error(stderr);
        reject(error);
      }
  
      resolve(stdout);
    });
  })
}

function getLastEpoch(pathToRepository) {
  const command = [
    `(${resetCmd}) > /dev/null 2>&1`,
    `git log --pretty=format:%ct -n1`
  ].join(' && ');

  return execute(command, pathToRepository).then(stdout => parseInt(stdout.trim(), 10));
}

function sanitize(string) {
  return string
    .replace(/\n/g, '\\n')
    .replace(/,/g, '","');
}

const collect = async (repo_name, json, pathToRepository) => {
  const data = JSON.parse(json);
  const lastEpoch = await getLastEpoch(pathToRepository);
  const survival = [];

  for (const type of Object.keys(data)) {
    const toggles = data[type];
    for (const toggleId of Object.keys(toggles)) {
      const events = toggles[toggleId];
      const firstEvent = events[0];
      const lastEvent = events[events.length - 1];
      const {
        commit: { commit: commitAdded, committerTs: committerTsAdded },
        toggle: { file: fileAdded, start: { line: lineAdded } },
      } = firstEvent;
      const {
        operation,
        toggle: { original_id, file: fileDeleted, start: { line: lineDeleted } },
        commit: { commit: commitDeleted, committerTs: committerTsDeleted }
      } = lastEvent;
      const t1 = parseInt(committerTsAdded, 10);
      const t2 = operation === 'DELETED' ? parseInt(committerTsDeleted, 10) : lastEpoch;
      survival.push({
        repo_name,
        toggle_id: sanitize(toggleId),
        original_id: sanitize(original_id),
        toggle_type: firstEvent.toggle.type,
        added: t1,
        lastSeen: t2,
        epoch_interval: t2 - t1,
        num_ops: events.length,
        num_modified_ops: events.filter(({ operation }) => operation === 'MODIFIED').length,
        removed: (lastEvent.operation === 'DELETED' ? 1 : 0),
        commit_added: commitAdded,
        commit_deleted: lastEvent.operation === 'DELETED' ? commitDeleted : null,
        file_added: fileAdded,
        file_deleted: lastEvent.operation === 'DELETED' ? fileDeleted : null,
        line_added: lineAdded,
        line_deleted: lastEvent.operation === 'DELETED' ? lineDeleted : null,
      });
    }
  }

  return survival;
};

if (require.main === module) {
  (async () => {  
    const repo_name = argv._[0];
    const json = fs.readFileSync(argv._[1]);
    const pathToRepository = argv._[2];
    const survival = await collect(repo_name, json, pathToRepository);
    console.log(Object.keys(survival[0]).join(','));
    survival.forEach((entry) => {
      console.log(Object.values(entry).join(','));
    });
  })();
}

exports.collect = collect;
exports.execute = execute;