# extraction

## 1. Extract the toggles from a set of projects using bulktractor

It is important to notice that these tools and the analysis preparation below heavily depend on `git`. Our experiments were run with `git version 2.17.2 (Apple Git-113)`. We recommend using that one or any recent version. In our experience, some previous versions gave the same results and others, usually older, did not.

Make sure you have installed [bulktractor@b259fbf](https://github.com/elhoyos/bulktractor/tree/b259fbf15d5c789218e689569098442320e79c94) and its dependencies correctly, and then run:

```bash
$ cd /path/to/bulktractor
$ DEBUG=commit-parser:progress \
PYTHON_PATH=`pyenv which python` \
SCRIPT_PATH=~/Projects/extractor-python \
REPOS_STORE=~/Projects/_repositories \
    python bulktractor.py \
        waffle_repositories.csv \
        toggles
```

## 2. Install dependencies

```bash
$ cd /path/to/extraction/analyze
$ npm install
$ brew install cloc
```

## 3. Prepare the extracted toggles for further analysis

```bash
$ REPOS_STORE=~/_repositories EXTRACTION=/path/to/bulktractor/toggles ./analyze/run.sh `ls -l /path/to/bulktractor/toggles/ | awk '{if ($9 && $9 != "README.md") printf ("%9s ", $9) }' | sed 's/\.json//g'`
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


## Traversal of extracted components

We manually walked the resulting feature toggles to group and classfiy the toggles and gain more insights from their removal. In the `analyze` folder you can find a set of scripts that will help you traverse and augment the extracted feature toggles of a project.

### Walk toggles

Traversing the toggles from the extracted JSON files can be tricky. `walk_survival.js` is a REPL tool that will help you:
- move through a list of toggles
- consolidate the components of a single feature toggle (same component type only)
- set a Hodgson classification
- save the resulting changes

To walk the Mozilla Bedrock routers you can run, for example:

```bash
$ node analyze/walk_survival.js \
    mozilla__bedrock analysis/raw/mozilla__bedrock/mozilla__bedrock.json \
    /home/me/research/repositories/mozilla__bedrock \
    Router

Walk a list of Routers/Points of a survival analysis.

Press 'j' (next) and 'k' (previous) to move along the list.
Press 'g' to enter into go-to-mode.

Press the number to set the toggle category:
1:RELEASE / 2:EXPERIMENT / 3:OPS / 4:PERMISSION / 0:UNKNOWN
Then, add a commment explaining the evidence to set the given category and press 'enter' to finish.
If you need to fix the comment, use '&' to start over.

Press '-' to unset the toggle category.

Press 'r' to reload the toggles data from the extracted json.

Press 's' to save the set toggles to a file.

Press Ctrl+C to exit.

> 
```

### Save the walked result to CSV

After walking and saving the compacted toggles of all projects in JSON files, you can convert these into a consolidated CSV file this way:

```bash
$ jq --slurp --raw-output --from-file analyze/short_long_as_csv.jq analysis/manual_walk/*.json > analysis/short_long.csv
```
