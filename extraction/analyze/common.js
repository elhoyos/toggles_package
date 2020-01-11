
const resetCmd = [
  'branch=`git symbolic-ref refs/remotes/origin/HEAD | sed \'s@^refs/remotes/origin/@@\'`',
  'git reset HEAD .',
  '(git checkout -- . || exit 0)', // keep going
  'git clean -f -d',
  'git checkout $branch',
].join(' && ');

const ID_TO_NAMES_REGEXS = [
  /-[0-9a-f]+$/, // matches the hash in my_feature-009873937372abcdef
  /.+\./, // matches everything until last dot in features.MY_FEATURE
  /.+?\n/, // matches everything until the last newline in "waffle.WAFFLE_NAMESPACE, waffle.\nMY_FEATURE"
  /\W/g, // matches non word characters in ('my_feature')
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
