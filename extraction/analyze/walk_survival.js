const readline = require('readline');
const fs = require('fs');
const argv = require('minimist')(process.argv.slice(2));
const { collect, execute } = require('./analyzers/survival');
const { asToggleName } = require('./common');
const { inspect } = require('util');

/*
* Walk a list of Routers of a survival analysis
*
* node walk_survival.js repo_name history.json "path/to/repository"
*/

const saveToggles = (toggles, filename) => {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(toggles, null, 2);
    fs.writeFile(filename, data, (err) => !err ? resolve() : reject(err));
  });
}

const loadSavedTypes = (filename) => {
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

const walk = (routers, filename) => {
  let index = -1;

  function printInstructions() {
    console.log([
      '',
      `Walk a list of Routers of a survival analysis.`,
      '',
      `Press 'j' (next) and 'k' (previous) to move along the list.`,
      `Press 'g' to enter into go-to-mode.`,
      '',
      'Press the number to set the toggle type:',
      '1:RELEASE / 2:EXPERIMENT / 3:OPS / 4:PERMISSION / 0:UNKNOWN',
      `Then, add a commment explaining the evidence to set the given type and press 'enter' to finish.`,
      `If you need to fix the comment, use '&' to start over.`,
      '',
      `Press '-' to unset the toggle type.`,
      '',
      `Press 's' to save the set toggle types to a file.`,
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
    const toggle = routers[ix];
    if (toggle) {
      index = ix;
    }
    return toggle;
  }

  function nextToggle() {
    return moveToToggle(index + 1);
  }

  function prevToggle() {
    return moveToToggle(index - 1);
  }

  function setType(toggle, type) {
    if (!toggle) return false;
    toggle.type = type;
    return true;
  }

  function unsetType(toggle) {
    if (!toggle) return false;
    delete toggle.type;
    delete toggle.type_comment;
    return true;
  }

  function setTypeComment(toggle, comment) {
    if (!toggle) return false;
    toggle.type_comment = comment;
    return true;
  }

  const state = {
    mode: '', // goto, random-type-set
    index: 0,
    toggle: null,
  };

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

  function typeCommentMode(key) {
    if (key !== '>>ENTER<<' && state.mode !== 'type-comment') return;

    switch(key) {
      case '>>ENTER<<':
        state.mode = 'type-comment';
        setTypeComment(state.toggle, '');
        break;
      case '\r':
        state.mode = '';
        break;
      case '&':
        setTypeComment(state.toggle, '');
        break;
      default:
        const comment = `${(state.toggle.type_comment || '')}${key}`;
        setTypeComment(state.toggle, comment);
        print(key);

        return; // do not print the prompt
    }

    if (state.mode === 'type-comment') {
      printPrompt('type-comment> ');
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

  const types = {
    '1': 'RELEASE',
    '2': 'EXPERIMENT',
    '3': 'OPS',
    '4': 'PERMISSION',
    '0': 'UNKNOWN',
  };

  process.stdin.on('keypress', async (key) => {
    goToMode(key);
    typeCommentMode(key);
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
        const type = types[key];
        if (!setType(state.toggle, type)) {
          print(`Cannot set a type to an unknown toggle, use 'j' or 'k' to move to a toggle.`);
        } else {
          typeCommentMode('>>ENTER<<');
          if (state.mode) return;
        }
        break;
      case '-':
        if (!unsetType(state.toggle)) {
          print(`Cannot unset a type to an unknown toggle, use 'j' or 'k' to move to a toggle.`);
        }
        break;
      case 's':
        print(`Saving toggles types...\n`);
        await saveToggles(routers, filename);
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

/*
* Suggests a type based on Hodgson's categories in a very lame way.
*
* This is lame because it only suggests RELEASE & OPS types, based on the
* number of weeks the toggle has survived.
*
* RELEASE: generally a week or two, could remain longer if feature is product-centric
* EXPERIMENT: several hours or weeks, depending on traffic
* OPS: more than several weeks
* PERMISSION: several months to years
*
* See: https://www.martinfowler.com/articles/feature-toggles.html
*/
function getLameSuggestedType(toggle) {
  const weeks = toggle.weeks_survived;

  if (weeks <= 2) {
    return 'RELEASE';
  } else {
    return 'OPS';
  }
}

function deleteObjectKeys(obj, keys) {
  const newObj = { ...obj };
  for (const key of keys) {
    delete newObj[key];
  }
  return newObj;
}

const WEEKS_IN_SEC = 60 * 60 * 24 * 7;

async function formatRouter(toggles, cwd) {
  const formatted = [];
  const numberOfToggles = toggles.length;
  let position = 1;
  for (const toggle of toggles) {
    const {
      toggle_id,
      repo_name,
      epoch_interval,
      commit_added,
      commit_deleted,
      file_added,
      file_deleted,
      line_added,
    } = toggle;
    const fmtToggle = {
      progress: `${position++} / ${numberOfToggles}`,
      name: asToggleName(toggle_id),
      ...toggle,
      weeks_survived: Math.ceil(epoch_interval / WEEKS_IN_SEC),
      commit_message_added: await getCommitMessage(commit_added, cwd),
      commit_message_deleted: commit_deleted ? await getCommitMessage(commit_deleted, cwd) : null,
      commit_link_added: getCommitLink(repo_name, commit_added),
      commit_link_deleted: commit_deleted ? getCommitLink(repo_name, commit_deleted) : null,
      link_added: getLink(repo_name, commit_added, file_added, line_added),
      git_diff_added: getGitDiffCmd(commit_added, file_added),
      git_diff_deleted: commit_deleted ? getGitDiffCmd(commit_deleted, file_deleted) : null,
    };

    fmtToggle.suggested_type = getLameSuggestedType(fmtToggle);

    formatted.push(
      deleteObjectKeys(fmtToggle, [
        'epoch_interval',
        'removed',
        'commit_added',
        'commit_deleted',
        'file_added',
        'file_deleted',
        'line_added',
        'line_deleted'])
    );
  }

  return formatted;
}

function formatRouter(cwd) {
  return async (router) => {
    const {
      toggle_id,
      repo_name,
      epoch_interval,
      commit_added,
      commit_deleted,
      file_added,
      file_deleted,
      line_added,
    } = router;

    const fmtRouter = {
      name: asToggleName(toggle_id),
      ...router,
      removed: router.removed === 1,
      weeks_survived: Math.ceil(epoch_interval / WEEKS_IN_SEC),
      commit_message_added: await getCommitMessage(commit_added, cwd),
      commit_message_deleted: commit_deleted ? await getCommitMessage(commit_deleted, cwd) : null,
      commit_link_added: getCommitLink(repo_name, commit_added),
      commit_link_deleted: commit_deleted ? getCommitLink(repo_name, commit_deleted) : null,
      link_added: getLink(repo_name, commit_added, file_added, line_added),
      git_diff_added: getGitDiffCmd(commit_added, file_added),
      git_diff_deleted: commit_deleted ? getGitDiffCmd(commit_deleted, file_deleted) : null,
    };

    fmtRouter.suggested_type = getLameSuggestedType(fmtRouter);

    return deleteObjectKeys(fmtRouter, [
      'epoch_interval',
      'commit_added',
      'commit_deleted',
      'file_added',
      'file_deleted',
      'line_deleted']);
  };
}

function formatToggle() {
  return (toggle, index, toggles) => {
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

    return {
      ...toggle,
      progress: `${index + 1} / ${toggles.length}`,
      all_routers_removed: routers.every(r => r.removed),
      first_seen_on: new Date(minTsAdded * 1000),
      last_seen_on: new Date(maxTsLastSeen * 1000),
      weeks_survived: Math.ceil((maxTsLastSeen - minTsAdded) / WEEKS_IN_SEC),
    };
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

(async () => {
  const repo_name = argv._[0];
  const json = fs.readFileSync(argv._[1]);
  const pathToRepository = argv._[2];
  const filename = `${repo_name.replace('/', '__')}.json`;

  let toggles = await loadSavedTypes(filename);
  if (!toggles) {
    const survival = await collect(repo_name, json, pathToRepository);
    toggles = await survival.filter(toggle => toggle.toggle_type === 'Router')
      .map(formatRouter(pathToRepository))
      .reduce(groupByToggleName, Promise.resolve([]));

    toggles = toggles.map(formatToggle());
  }

  walk(toggles, filename);
})();
