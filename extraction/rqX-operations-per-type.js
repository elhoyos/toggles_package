const fs = require('fs');
const argv = require('minimist')(process.argv.slice(2));
const repo_name = argv._[0];
const json = fs.readFileSync(argv._[1]);
const data = JSON.parse(json);

/*
* Prints a csv with the number of operations per toggle component
*
* Usage:
* node rqX-operations-per-type.js repo_name history.json
*/

const counts = {
  // 'Declaration': { ADDED: 0, MODIFIED: 0, DELETED: 0, count: 0 },
  'Router': { ADDED: 0, MODIFIED: 0, DELETED: 0, count: 0 },
  'Point': { ADDED: 0, MODIFIED: 0, DELETED: 0, count: 0 },
};

const names = new Set();
const ID_TO_NAMES_REGEXS = [
  /-[0-9a-f]+$/, // matches the hash in my_feature-009873937372abcdef
  /.+\./, // matches everything until last dot in features.MY_FEATURE
  /.+?\n/, // matches everything until the last newline in "waffle.WAFFLE_NAMESPACE, waffle.\nMY_FEATURE"
  /\W/g, // matches non word characters in ('my_feature')
];
function asToggleName(_id) {
  return ID_TO_NAMES_REGEXS.reduce((id, regex) => id.replace(regex, ''), _id);
}

Object.keys(counts).forEach((type) => {
  const components = data[type];
  counts[type]['count'] =+ Object.values(components).length;
  Object.values(components).forEach((events) => {
    events.forEach((event) => {
      const { operation, toggle } = event;
      const { id } = toggle;

      if (operation === 'ADDED' && type === 'Router') {
        names.add(asToggleName(id));
      }

      counts[type][operation] += 1;
    });
  });
});

const listsAsHeaders = (a, b, callback) => {
  return a
    .map((aItem) => b.map(bItem => callback(aItem, bItem)))
    .reduce((memo, item) => {
      return memo.concat(item);
    }, []).join(',')
};

const types = Object.keys(counts);
const operations = ['ADDED', 'MODIFIED', 'DELETED'];
const header = listsAsHeaders(types, operations, (type, op) => `${op}-${type}`);
const numbers = listsAsHeaders(types, operations, (type, op) => counts[type][op]);
const num_toggles_aprox = names.size;

console.log(`repo_name,${header},num_toggles_aprox`)
console.log(`${repo_name},${numbers},${num_toggles_aprox}`)
