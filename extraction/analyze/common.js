
const resetCmd = [
  'branch=`git symbolic-ref refs/remotes/origin/HEAD | sed \'s@^refs/remotes/origin/@@\'`',
  'git reset HEAD .',
  '(git checkout -- . || exit 0)', // keep going
  'git clean -f -d',
  'git checkout $branch',
].join(' && ');

module.exports = {
  resetCmd,
};
