# git-log issue sampling

From our threats to validity:

> Moreover, git-log is heavily trusted by extractor, and it does not have a 100% accuracy when tracing historic changes in the source code. This limitation will cause the same toggle compo nent to be removed and then added like if a different one, and in consequence our quantitative approach results could be affected. We have not measured how much of this situation occurs in our experiments.

## Potential consequences

Toggle component being treated as a different toggle component whereas is the same. extractor finds there is no history for the component being evaluated and treats it as a new component.

The number of added & deleted toggle components are lower in reality.

Does it affect the routers-points ratio?

>In our analysis we found that Waffle projects introduced 16% more Routers than Points on a median. Also, 42% of the projects introduced between 40% to 75% more Routers; however, after the practitioners of these projects removed feature toggles from the code, the ratio of remaining Routers per Points increased in all but course-discovery

## Mitigations already in place

### Fallback strategy to git-log

When git-log fails to properly find a matching previous component, extractor attempts a second strategy that matches any previous component in the same file and line number as the component being evaluated.

### Normalize aggregated data

Extracted toggle components are aggregated by `original_id` and a normalized toggle name.

* Tracing components by `original_id` allows to follow the history of the original component correctly as determined by extractor.

* Toggle names are normalized both [in extractor-python](https://gitlab.com/juan.hoyosr/extractor-python/-/blob/02954dd4d315f2b4a8a7058ae5dac2bc48d329a5/libraries/django_waffle/components.py#L164) and [in the aggregation script](https://github.com/elhoyos/toggles_package/blob/004646e36c0c5be2eb7a1d019678051bbb795557/extraction/analyze/common.js#L12). Both normalizations are different in nature but when combined serve the purpose of using the toggle name to identify the same toggle component regardless of the strategies to match the history of toggle components.

One possible problem with the name normalization and matching occurs when two unrelated toggles with the same name are found in the same project and are matched as the same. This happens when a toggle name is reused despite a discouraged practice (Knight Capital case).

Another problem with the name normalization is that it only works for Routers or other components that include information about the name of the toggle. At this moment the extracted information of the Points do not include their related Routers, and cannot benefit for the name normalization.

Another problem could happen when the name in the Routers of a single toggle do not match. Because, for example, the developers used a name in a variable in one Router, but the direct name in another.


## Sampling method

After mitigation, how much of this issue happens?

Let's do a 5% random sample and check if these toggles suffer from this problem.

Total number of toggles: 322 (approx.)

5% of toggles = 322 * 0.05 ~ 16 toggles

Choose a random number between 1 and 322 and analyze all the components of the toggle that contains the toggle number indicated by the random number, where the toggles are organized in ascending order per project as listed in "Table 3: 12 Python projects using feature toggles with Waffle." and in the Routers of `analysis/raw/[project_name]/survival.csv` inside each project.

### How to analyze?

Use `analyze/walk_survival.js` for convenience.


#### To check if the fallback strategy fails
For each component:
* Same Router appears as added after being deleted in the same commit?
  - Find the Routers of the toggle in `analyze/done/[project_name].json` and answer the question
* Same Point appears as added after being deleted in the same commit?
  - Run `node walk_survival.js repo_name history.json "path/to/repository" Point`
  - Answer "no" if no Router file appears in `jq -C '. | flatten | map(select(.num_routers > 1) | .name)' walk_results.json | less -R`
  - For the matching entries, identify the Points of the toggle in `walk_results.json` and answer the question


#### To check for issues with normalized names
For each Router:
* Name is reused
* Name normalization fails. See entries with the `group_as` key in `analyze/walk_survival.js` results in `analyze/done/[project_name].json`.

### Results

#| Toggle number | Project | Toggle name | Same Router added & deleted | Same Point added & deleted | Has Routers with `group_as`| Notes
-|-|-|-|-|-|-|-
1|33|zamboni|unleash-consumer|no|no|no|--
2|142|course-discovery|publisher_approval_widget_feature|no|no|no|Routers assigned to template context, Points not found.
3|26|zamboni|personas-migration-completed|**yes**|**yes**|no|Significant refactor. Functionality-wise found the same Router & Point added & deleted at same commit in `test_views.py`.
4|156|course-discovery|PUBLISHER_REMOVE_START_DATE_EDITING|no|no|**yes**|Renamed to PUBLISHER_REMOVE_PACING_TYPE_EDITING.
5|96|ecommerce|CLIENT_SIDE_CHECKOUT_FLAG_NAME|**yes**|**yes**|no|Significant refactor. Functionality-wise found the same Router & Point added & deleted at same commit in `views.py`.
6|136|course-discovery|parallel_refresh_pipeline|no|no|no|--
7|275|Jiller|push_issue|**yes**|**yes**|no|Significant refactor, abstracted functionality to other files. Functionality-wise found the same Router & Point added & deleted at same commit in `views.py`.
8|83|zamboni|desktop-payments|no|no|no|Routers assigned toggle state to variables, Points not found.
9|281|Jiller|read_workflow_manager|no|no|no|Routers were not deleted.
10|112|ecommerce|DISABLE_REPEAT_ORDER_CHECK_SWITCH_NAME|**yes**|**yes**|**yes**|Substantial refactor, moved the toggle to another file. Renamed from REPEAT_PURCHASE_SWITCH_NAME.
11|12|zamboni|perf-tests|no|no|no|--
12|280|Jiller|edit_sprint|no|no|no|--
13|105|ecommerce|add-utm-params|no|no|no|--
14|286|wardenclyffe|vital_uploads|**yes**|**yes**|no|Commits and components operations do not match. Found deleted ops for Routers and Points after adding the same component in `stats.html`.
15|148|course-discovery|enable_publisher_create_course_run_in_studio|no|no|no|--
16|78|zamboni|in-app-products|no|no|no|--

#### Highlights

* The fallback strategy fail was found in 31.25% of the samples.
* The name normalization fail was found in 12.5% of the samples.
* Both failures were found in one sample (~6%).

## Conclusions

The results indicate that the normalization mitigation could help to solve about 40% of the fallback strategy failures at analysis time if Routers are used.

Another interesting takeaway is that the issues in Routers and Points fail at the same rate for each toggle component type. This means that whenever a Router is added->deleted and then wrongly added again, the history of the associated Point is the same. Because of this reason and because we work with proportions, the routers-points ratio analysis is not affected by this issue.

Tracing toggle components using git-log is a challenging task. In our experiment, extractor was capable to trace a 69% of the toggle components accurately.

Determining when a toggle component is being moved from a location within a file or a project is found to be specially subjective, due to the available context to the researcher. In our case, we are not related in any way with the projects and this context is usually very limited, thus, it required a significant amount of time and skills to find satisfactory evidence.
