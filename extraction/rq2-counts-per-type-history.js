const fs = require('fs');
const argv = require('minimist')(process.argv.slice(2));
const json = fs.readFileSync(argv._[0]);
const data = JSON.parse(json);

/*
* Prints a csv with the number of operations per toggle component
*
* Usage:
* node rq2-counts-per-type-history.js repo_name history.json
*/

const counts = {
  'Declaration': { ADDED: 0, MODIFIED: 0, DELETED: 0, count: 0 },
  'Router': { ADDED: 0, MODIFIED: 0, DELETED: 0, count: 0 },
  'Point': { ADDED: 0, MODIFIED: 0, DELETED: 0, count: 0 },
};

Object.keys(data).forEach((type) => {
  const toggles = data[type];
  counts[type]['count'] =+ Object.values(toggles).length;
  Object.values(toggles).forEach((events) => {
    events.forEach((event) => {
      counts[type][event.operation] += 1;
    });
  });
});

console.log(`project,operation,${Object.keys(counts).join(',')}`)
console.log(`ADDED,${Object.keys(counts).map(type => counts[type].ADDED).join(',')}`)
console.log(`MODIFIED,${Object.keys(counts).map(type => counts[type].MODIFIED).join(',')}`)
console.log(`DELETED,${Object.keys(counts).map(type => counts[type].DELETED).join(',')}`)

// console.log(`variable,value`)
// Object.keys(counts).forEach((type) => {
//   console.log(`${type},${counts[type].count}`);
// });
