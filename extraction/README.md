# extraction

1. Extract the toggles from a set of projects using bulktractor

Make sure you have installed [bulktractor](https://github.com/elhoyos/bulktractor) and its dependencies correctly, and then run:

```bash
$ DEBUG=commit-parser:progress \
PYTHON_PATH=`pyenv which python` \
SCRIPT_PATH=~/Projects/extractor-python \
REPOS_STORE=~/Projects/_repositories \
    python bulktractor.py \
        waffle_repositories.csv \
        toggles
```


2. Install dependencies:

```bash
$ npm install
$ brew install cloc
```

3. Prepare the toggles for a further analysis:

```bash
$ REPOS_STORE=~/Projects/_repositories ./prepare-toggles.sh `ls -l bulktractor/toggles/ | awk '{if ($9 && $9 != "README.md") printf ("%9s ", $9) }' | sed 's/\.json//g'`
```

### Useful scripts

Unique toggle names (requires [`jq`](https://stedolan.github.io/jq/)):

```bash
$ ls bulktractor/toggles/*.json | awk -F ' ' '{print $1}' | xargs -I % jq --raw-output '.Router | to_entries | map(.value) | flatten | map(select(.operation == "ADDED")) | .[] | .toggle.id | sub("-[0-9a-f]+$"; "") | gsub("\\x27"; "") | sub(".+\\."; "") | ascii_downcase' % | sort > toggle_names.txt
```

Prepare all extracted toggle components and summarize:

```bash
$ REPOS_STORE=~/_repositories ./prepare-toggles.sh `ls -l bulktractor/toggles/ | awk '{if ($9) printf ("%9s ", $9) }' | sed 's/\.json//g'`
```

