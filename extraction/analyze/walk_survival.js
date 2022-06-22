const readline = require('readline');
const fs = require('fs');
const argv = require('minimist')(process.argv.slice(2));
const { collect, execute } = require('./analyzers/survival');
const { asToggleName } = require('./common');
const { inspect } = require('util');

/*
* Walk a list of Routers/Points of a survival analysis
*
* node walk_survival.js repo_name history.json "path/to/repository" [Router|Point]
*/

const getArgs = () => {
  return {
    repo_name: argv._[0],
    json: fs.readFileSync(argv._[1]),
    pathToRepository: argv._[2],
    componentType: argv._[3] || 'Router',
  };
}

const saveToggles = (toggles, filename) => {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(toggles, null, 2);
    fs.writeFile(filename, data, (err) => !err ? resolve() : reject(err));
  });
}

const loadSavedToggles = (filename) => {
  return new Promise((resolve, reject) => {
    fs.readFile(filename, (err, data) => {
      if (err) {
        if (err.code !== 'ENOENT') return reject(err);
        return resolve(null);
      }
      const routers = JSON.parse(data);
      resolve(routers);
    });
  });
}

const walk = (toggles, filename) => {
  let index = -1;

  const state = {
    mode: '',
    index: 0,
    toggle: null,
    toggles,
  };

  function printInstructions() {
    console.log([
      '',
      `Walk a list of Routers/Points of a survival analysis.`,
      '',
      `Press 'j' (next) and 'k' (previous) to move along the list.`,
      `Press 'g' to enter into go-to-mode.`,
      '',
      'Press the number to set the toggle category:',
      '1:RELEASE / 2:EXPERIMENT / 3:OPS / 4:PERMISSION / 0:UNKNOWN',
      `Then, add a commment explaining the evidence to set the given category and press 'enter' to finish.`,
      `If you need to fix the comment, use '&' to start over.`,
      '',
      `Press '-' to unset the toggle category.`,
      '',
      `Press 'r' to reload the toggles data from the extracted json.`,
      '',
      `Press 's' to save the set toggles to a file.`,
      '',
      `Press Ctrl+C to exit.`,
    ].join('\n'));
  }

  function printGoToModeInstructions() {
    console.log([
      '',
      `Enter the position in the list of the toggle you want to be displayed.`,
      `Press 'q' (quit) to exit go-to-mode`,
    ].join('\n'));
  }

  function print(string) {
    process.stdout.write(string);
  }

  function printPrompt(prompt = '> ') {
    print(`\n${prompt}`);
  }

  function printToggle(toggle) {
    print(`\n${inspect(toggle, { colors: true, compact: false, breakLength: Infinity })}`);
  }

  function moveToToggle(ix) {
    const toggle = state.toggles[ix];
    if (toggle) {
      index = ix;
    }
    return toggle;
  }

  function reloadTogglesData(extracted) {
    const currents = [].concat(state.toggles);
    
    state.toggles = extracted
      .map((toggle) => {
        const { toggle_id } = toggle.routers[0];

        return currents
          .filter(({ routers, group_as }) => {
            const groups = new Set([].concat(group_as));
            return (
              routers[0].toggle_id === toggle_id ||
              groups.has(toggle_id)
            );
          })
          .reduce((merged, current, _ix, { length }) => {
            current.__seen = true;
            const { category, category_comment, group_as } = current;
            const isToggleWithGroupAs = length === 1;

            // group_as is a hack to solve some cases where extractor is not capable
            // to trace same toggles
            let routers = [...merged.routers];
            if (!isToggleWithGroupAs && group_as) {
              const { routers: [{ toggle_id: currentToggleId }] } = current;
              // use extracted routers to get a proper toggle formatting
              const { routers: groupedRouters } = extracted.find(t => t.routers[0].toggle_id === currentToggleId);
              routers = [...merged.routers, ...groupedRouters];
            }

            return {
              ...merged,
              routers,
              category,
              category_comment,
              group_as: isToggleWithGroupAs ? group_as : undefined,
            };
          }, { ...toggle });
      })
      // computed formatting could have changed by group_as toggles
      .map(formatToggle);

    const notSeen = currents.filter(t => t.__seen !== true);
    if (notSeen.length) {
      throw new Error(`ERROR: Can't find extracted matches of ${notSeen.map(notSeen.name)}`);
    }
  }

  function nextToggle() {
    return moveToToggle(index + 1);
  }

  function prevToggle() {
    return moveToToggle(index - 1);
  }

  function getToggle() {
    return state.toggles[index];
  }

  function setCategory(toggle, category) {
    if (!toggle) return false;
    toggle.category = category;
    return true;
  }

  function unsetCategory(toggle) {
    if (!toggle) return false;
    delete toggle.category;
    delete toggle.category_comment;
    return true;
  }

  function setCategoryComment(toggle, comment) {
    if (!toggle) return false;
    toggle.category_comment = comment;
    return true;
  }

  function goToMode(key) {
    if (key !== '>>ENTER<<' && state.mode !== 'goto') return;

    switch(key) {
      case '>>ENTER<<':
        printGoToModeInstructions();
        state.mode = 'goto';
        break;
      case 'q':
        state.mode = '';
        break;
      case '\r':
        state.toggle = moveToToggle(state.index - 1);
        state.mode = '';
        state.index = 0;
        break;
      default:
        const number = parseInt(key, 10);
        if (!isNaN(number)) {
          state.index = state.index * 10 + number;
          print(number + '');
        }

        return; // do not print the prompt
    }

    if (state.mode === 'goto') {
      printPrompt('goto> ');
    }
  }

  function writeCategoryCommentMode(key) {
    if (key !== '>>ENTER<<' && state.mode !== 'category-comment') return;

    switch(key) {
      case '>>ENTER<<':
        state.mode = 'category-comment';
        setCategoryComment(state.toggle, '');
        break;
      case '\r':
        state.mode = '';
        break;
      case '&':
        setCategoryComment(state.toggle, '');
        break;
      default:
        const comment = `${(state.toggle.category_comment || '')}${key}`;
        setCategoryComment(state.toggle, comment);
        print(key);

        return; // do not print the prompt
    }

    if (state.mode === 'category-comment') {
      printPrompt('category-comment> ');
    }
  }

  function exit() {
    console.log('Bye!');
    process.exit(0);
  }

  readline.emitKeypressEvents(process.stdin);
  if (process.stdin.isTTY) {
    process.stdin.setRawMode(true);
  }

  const rl = readline.createInterface({
    input: process.stdin,
    output: null,
    terminal: true,
  });

  printInstructions();

  printPrompt();

  const categories = {
    '1': 'RELEASE',
    '2': 'EXPERIMENT',
    '3': 'OPS',
    '4': 'PERMISSION',
    '0': 'UNKNOWN',
  };

  process.stdin.on('keypress', async (key) => {
    goToMode(key);
    writeCategoryCommentMode(key);
    if (state.mode) return;

    switch (key) {
      case 'j':
        state.toggle = nextToggle();
        break;
      case 'k':
        state.toggle = prevToggle();
        break;
      case 'g':
        goToMode('>>ENTER<<');
        if (state.mode) return;
        break;
      case '1':
      case '2':
      case '3':
      case '4':
      case '0':
        const category = categories[key];
        if (!setCategory(state.toggle, category)) {
          print(`Cannot set a category to an unknown toggle, use 'j' or 'k' to move to a toggle.`);
        } else {
          writeCategoryCommentMode('>>ENTER<<');
          if (state.mode) return;
        }
        break;
      case '-':
        if (!unsetCategory(state.toggle)) {
          print(`Cannot unset a category to an unknown toggle, use 'j' or 'k' to move to a toggle.`);
        }
        break;
      case 'r':
        print('Reloading extracted toggles data...\n');
        const toggles = await loadTogglesFromExtraction(getArgs());
        reloadTogglesData(toggles);
        state.toggle = getToggle();
        break;
      case 's':
        print(`Saving toggles...\n`);
        await saveToggles(state.toggles, filename);
        print(`Saved to ${filename}`);
        break;
      case '?':
        printInstructions();
        break;
    }

    if (state.toggle) {
      printToggle(state.toggle);
    }

    printPrompt();
  });

  rl.on('close', () => {
    exit();
  });
};

function getCommitMessage(hash, cwd) {
  const command = `git log --pretty=format:%B -n1 ${hash}`;
  return execute(command, cwd).then(stdout => stdout.trim());
}

function getCommitLink(repo_name, hash) {
  return `https://github.com/${repo_name}/commit/${hash}`;
}

function getLink(repo_name, hash, filepath, startLine) {
  return `https://github.com/${repo_name}/blob/${hash}/${filepath}#L${startLine}`;
}

function getGitDiffCmd(hash, filepath) {
  return `git diff ${hash}^ ${hash} -- ${filepath}`;
}

function deleteObjectKeys(obj, keys) {
  const newObj = { ...obj };
  for (const key of keys) {
    delete newObj[key];
  }
  return newObj;
}

const WEEKS_IN_SEC = 60 * 60 * 24 * 7;

function formatComponent(cwd, nameFn) {
  return async (component) => {
    const {
      repo_name,
      epoch_interval,
      commit_added,
      commit_deleted,
      file_added,
      file_deleted,
      line_added,
    } = component;

    const fmtRouter = {
      name: nameFn(component),
      ...component,
      removed: component.removed === 1,
      weeks_survived: Math.ceil(epoch_interval / WEEKS_IN_SEC),
      commit_message_added: await getCommitMessage(commit_added, cwd),
      commit_message_deleted: commit_deleted ? await getCommitMessage(commit_deleted, cwd) : null,
      commit_link_added: getCommitLink(repo_name, commit_added),
      commit_link_deleted: commit_deleted ? getCommitLink(repo_name, commit_deleted) : null,
      link_added: getLink(repo_name, commit_added, file_added, line_added),
      git_diff_added: getGitDiffCmd(commit_added, file_added),
      git_diff_deleted: commit_deleted ? getGitDiffCmd(commit_deleted, file_deleted) : null,
    };

    return deleteObjectKeys(fmtRouter, [
      'epoch_interval',
      // 'commit_added', // need this for groupByDeletedWhenAdded
      'commit_deleted',
      // 'file_added', // need this for groupByDeletedWhenAdded
      'file_deleted',
      'line_deleted']);
  };
}

async function groupByToggleName(togglesPromise, routerPromise) {
  const router = await routerPromise;
  const { name, repo_name } = router;
  const toggles = await togglesPromise;
  const index = toggles.findIndex(t => t.name === name);
  const toggle = index > -1 ? toggles[index] : {
    progress: '',
    name,
    repo_name,
    num_routers: 0,
    routers: [],
  };
  
  const { routers } = toggle;
  routers.push(router);
  toggle.num_routers++;
  if (index === -1) toggles.push(toggle);
  return toggles;
}

async function groupByDeletedWhenAdded(togglesPromise, componentPromise) {
  const component = await componentPromise;
  const { name, commit_added, file_added, repo_name } = component;
  const toggles = await togglesPromise;
  // name is commit_deleted_file_added
  const index = toggles.findIndex(t => t.name === `${commit_added}_${file_added}`);
  const toggle = index > -1 ? toggles[index] : {
    progress: '',
    name,
    repo_name,
    num_routers: 0,
    routers: [],
  };
  
  const { routers } = toggle;
  routers.push(component);
  toggle.num_routers++;
  if (index === -1) toggles.push(toggle);
  return toggles;
}

async function groupByOriginalId(togglesPromise, componentPromise) {
  const component = await componentPromise;
  const { original_id, repo_name } = component;
  const toggles = await togglesPromise;
  const index = toggles.findIndex(t => t.original_id === original_id);
  const toggle = index > -1 ? toggles[index] : {
    progress: '',
    name: original_id,
    repo_name,
    num_routers: 0,
    routers: [],
  };
  
  const { routers } = toggle;
  routers.push(component);
  toggle.num_routers++;
  if (index === -1) toggles.push(toggle);
  return toggles;
}

function formatToggle(toggle, index, toggles) {
  const {
    routers
  } = toggle;

  const [minTsAdded, maxTsLastSeen] = routers.reduce((timestamps, router) => {
    let [min, max] = timestamps;
    const { added, lastSeen } = router;
    if (min > added) min = added;
    if (max < lastSeen) max = lastSeen;
    return [min, max];
  }, [Infinity, -Infinity]);

  // Cleanup a bit more the routers
  toggle.routers = routers.map((router) => deleteObjectKeys(router, [
    'name',
    'repo_name',
    'added',
    'lastSeen',
  ]));

  const categoryData = {
    category: toggle.category,
    category_comment: toggle.category_comment,
    group_as: toggle.group_as,
  };

  // keep category data at the bottom for easier access
  delete toggle.category;
  delete toggle.category_comment;
  delete toggle.group_as;

  return {
    ...toggle,
    progress: `${index + 1} / ${toggles.length}`,
    all_routers_removed: routers.every(r => r.removed),
    first_seen_on: new Date(minTsAdded * 1000),
    last_seen_on: new Date(maxTsLastSeen * 1000),
    weeks_survived: Math.ceil((maxTsLastSeen - minTsAdded) / WEEKS_IN_SEC),
    ...categoryData,
  };
}

const nameFnByComponentType = (componentType) => {
  switch(componentType) {
    case 'Point':
      return ({ commit_deleted, file_deleted }) => `${commit_deleted}_${file_deleted}`;
    case 'Router':
    default:
      return ({ toggle_id }) => asToggleName(toggle_id);
  }
};

const groupFnByComponentType = (componentType) => {
  return {
    'Router': groupByToggleName,
    'Point': groupByOriginalId,
  }[componentType];
}

async function loadTogglesFromExtraction({ repo_name, json, pathToRepository, componentType }) {
  const survival = await collect(repo_name, json, pathToRepository);
  const format = formatComponent(pathToRepository, nameFnByComponentType(componentType));
  const group = groupFnByComponentType(componentType);
  return survival.filter(toggle => toggle.toggle_type === componentType)
    .map(format)
    .reduce(group, Promise.resolve([]));
}

(async () => {
  const args = getArgs();
  const { repo_name } = args;
  const filename = `${repo_name.replace('/', '__')}.json`;

  let toggles = await loadSavedToggles(filename);
  if (!toggles) {
    toggles = (await loadTogglesFromExtraction(args))
      .map(formatToggle);
  }

  walk(toggles, filename);
})();
