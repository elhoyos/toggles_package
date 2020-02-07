
const resetCmd = [
  'branch=`git symbolic-ref refs/remotes/origin/HEAD | sed \'s@^refs/remotes/origin/@@\'`',
  'git reset HEAD .',
  '(git checkout -- . || exit 0)', // keep going
  'git clean -f -d',
  'git checkout $branch',
].join(' && ');

const ID_TO_NAMES_REGEXS = [
  // text before the 64 char hex is already cleaned up
  /-[0-9a-f]{64}(?:-\d+)?$/, // matches the hash in my_feature-with-dashes-009873937372abcdef-1234
];

/*
* Extracts the name of a toggle from its id.
*/
function asToggleName(_id) {
  return ID_TO_NAMES_REGEXS.reduce((id, regex) => id.replace(regex, ''), _id);
}

module.exports = {
  resetCmd,
  asToggleName,
};
