const fs = require('fs');
const argv = require('minimist')(process.argv.slice(2));
const json = fs.readFileSync(argv._[0]);
const data = JSON.parse(json);

/*
* Finds the living Routers that have no living Point
*
* Usage:
* node living-routers-without-point.js history.json
*
* Make the output more readable:
* node living-routers-without-point.js history.json | jq -C '. | map({ id: .toggle.id, operation: .operation}) | flatten'
*/

// Gather latest living versions of all toggles
const routers = {};
const points = {};
['Router', 'Point'].forEach((type) => {
  const toggles = data[type];
  Object.values(toggles).forEach((events) => {
    events.forEach((event) => {
      const { toggle, operation } = event;
      const { original_id, type } = toggle;
      const memo = type === 'Router' ? routers : points;
      // use original_id to follow the same toggle component
      memo[original_id] = { ...event };
      if (operation === 'DELETED') {
        delete memo[original_id];
      }
    });
  });
});

routersIds = Object.keys(routers);
pointsIds = Object.keys(points);
if (pointsIds.length > routersIds.length) {
  throw new Error(`Unexpected number of Points (${pointsIds.length}) exceed Routers (${routersIds.length})`);
}

function lookupRouterPoints(pendingPoints, router) {
  const { toggle: { file: rFile, start: { line: rStart }, end: { line: rEnd } } } = router;
  return pendingPoints.filter(({ toggle: { file: pFile, start: { line: pStart }, end: { line: pEnd } }}) => {
    return rFile === pFile
      && rStart >= pStart
      && rEnd <= pEnd;
  });
}

function seePoints(pendingPoints, points) {
  let pendingToRemove = points.length;
  for (let i = pendingPoints.length - 1; i >= 0; i--) {
    const notSeenPoint = pendingPoints[i];
    if (points.some(point => point.original_id === notSeenPoint.original_id)) {
      pendingPoints.splice(i, 1);
      if (--pendingToRemove === 0) break;
    }
  }
}

const ID_TO_NAMES_REGEXS = [
  /-[0-9a-f]+$/, // matches the hash in my_feature-009873937372abcdef
  /.+\./, // matches everything until last dot in features.MY_FEATURE
  /.+?\n/, // matches everything until the last newline in "waffle.WAFFLE_NAMESPACE, waffle.\nMY_FEATURE"
  /\W/g, // matches non word characters in ('my_feature')
];
function asToggleName(_id) {
  return ID_TO_NAMES_REGEXS.reduce((id, regex) => id.replace(regex, ''), _id);
}

// Map types
const lonelyRouters = [];
const seenPoints = pointsIds.map(id => points[id]);
const allLivingPoints = [...seenPoints]; // match Points with multiple Routers
routersIds.reduce((memo, routerId) => {
  const router = routers[routerId];
  const points = lookupRouterPoints(allLivingPoints, router);
  if (points.length === 0) {
    router.name = asToggleName(router.toggle.id)
    memo.push(router);
  } else {
    seePoints(seenPoints, points);
  }

  return memo;
}, lonelyRouters);

if (seenPoints.length > 0) {
  throw new Error(`Unexpected Points without Routers (${seenPoints.length}): ${JSON.stringify(seenPoints.map(p => p.toggle.id))}`);
}

console.log(JSON.stringify(lonelyRouters));
