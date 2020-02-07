## rhelmer/socorro-webapp (Removed)

A copy of mozilla-services/socorro.

First commit between repositories do not match.

In socorro-webapp:
commit 64c7d87e8e331065be8d812bdb4f2a1f44790eb8
Author: lonnen <chris.lonnen@gmail.com>
Date:   Wed Jul 17 19:52:02 2013 -0700

    merge socorro-crashstats into webapp-django

In socorro:
commit 315d561d2a20f2b130ee620b3803710a09d6dc02
Author: (no author) <(no author)@efcc4bdc-162a-0410-a8af-5b4b46c5376d>
Date:   Thu Feb 22 20:53:00 2007 +0000

    Initial directory structure.

    git-svn-id: https://socorro.googlecode.com/svn/trunk@1 efcc4bdc-162a-0410-a8af-5b4b46c5376d

Four commits add toggles. All of them appear in mozilla's.

Two commits delete toggles appearing also in mozilla's repository but with different hash:

```
$ jq -C '.Router | to_entries | map(.value) | flatten | map(select(.operation != "ADDED" and .operation != "CONTEXT_CHANGED") | { commit: .commit.commit, op: .operation, oid: .toggle.original_id, file: .toggle.file }) | sort_by(.oid)' ../../tmp/extraction/ignored/rhelmer__socorro-webapp/rhelmer__socorro-webapp.json | less -R
```

https://github.com/rhelmer/socorro-webapp/commit/d802c4fff11872cd07c1b5b5b5eb045fb300216f
https://github.com/rhelmer/socorro-webapp/commit/41442343730d3d9970ec5b74e8eb88e2dc60c3f7

No commits modify toggles.

## mwaaas/django-waffle-session (Removed)

A copy of django-waffle, the library.



## OPI-PIB/edx-platform-private (Removed)

This project is a copy of edx/edx-platform. All of its toggles appear at first commit and no toggle got modified/deleted.

```
$ jq -C '.Router | to_entries | map(.value) | flatten | map(select(.operation != "ADDED") | { commit: .commit.commit, op: .operation })'
 analysis/raw/OPI-PIB__edx-platform-private/OPI-PIB__edx-platform-private.json | less -R
```

https://github.com/OPI-PIB/navoica-platform/commit/75171af5126a655ee3f4c7956d685423b9d60e85

Not picked by the filter because the first commit hash is not the same.


## hwjworld/xiaodun-platform (Kept)

Keeping this repository. Some reasons:

First, README suggests this is a platform based on edX's, targeted to custom purposes.

Second, the toggle `merge_course_tabs` was added and is not part of edx/edx-platform.
https://github.com/hwjworld/xiaodun-platform/commit/252e566b848202d45a66e571520c3a7add6626fb#diff-85a44cf8158a971557b659ecafacf92a

```
$ jq -C '.Router | to_entries | map(.value) | flatten | map(select(.operation == "ADDED" and .commit.commit == "19c5eeaf25906e3c7c398a22246d1c5d9727016b") | .toggle)' analysis/raw/edx__edx-platform/edx__edx-platform.json | less -R
```

## ccmtl/ssnm (Removed):

This project was picked because it only contains an internal copy of django-waffle, no usages from it.

```
$ jq '.Router | to_entries | map(.value) | flatten | map(.toggle.file) | .[]' ~/research/toggles_package/extraction/analysis/raw/ccnmtl__ssnm/ccnmtl__ssnm.json | sort | uniq
"ve/lib/python2.7/site-packages/waffle/helpers.py"
"ve/lib/python2.7/site-packages/waffle/templatetags/waffle_tags.py"
"ve/lib/python2.7/site-packages/waffle/tests/test_waffle.py"
"ve/lib/python2.7/site-packages/waffle/views.py"
```