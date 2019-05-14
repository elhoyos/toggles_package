const fs = require('fs');
const argv = require('minimist')(process.argv.slice(2));
const json = fs.readFileSync(argv._[0]);
const toggles = JSON.parse(json);

const counts = {
  'Declaration': 0,
  'Router': 0,
  'Point': 0,
};

toggles.forEach((toggle) => {
  counts[toggle.type] += 1;
});

console.log(Object.keys(counts).join(','))
console.log(Object.keys(counts).map(type => counts[type]).join(','))
