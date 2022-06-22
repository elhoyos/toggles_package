# Toggles surviving after week 49

We want to uncover how do toggles surviving after week 49 look like. How many of these are short-term?

75% of the toggle components are removed within 49 weeks after introduction. This observation was made using only the points representing the toggle components. We choose solely points because we saw no statistical difference between points and routers and because points usually affect more lines of code than routers and, thus, they are harder to remove from the source code, which is more interesting.

If we stick to points, 25% of all the reported toggles in Table 3 (created using routers) gives 80.5 toggles, but the actual number of routers living more than 49 weeks is 103.  This looks wrong from the readers perspective.

To make it worse, 25% of the routers survived after 110.5 weeks (grouped by name as formatted by `walk_survival.js`) and the actual number of living routers is 61, still not 80 as expected from Table 3.

The reasons of these incongruencies are:
1. Using points for the RQ1 results vs using routers for the Table 3
2. RQ1's survival weeks are computed using the max time of points grouped by `original_id`
3. `walk_survival` computes the survived weeks of the toggle by obtaining the min & max times of each component

Still, I consider RQ1 is on the right track when using maximum times, but maybe a better approach could be to compute that maximum time for routes of the same component (by name). This could be better because we are limited to find points when a router is present, and not the other way.

## Solution

We are in a minor revision, RQ1 should not be changed, thus, we stick to the 75%-49 weeks.

We choose to analyze 103 toggles out of 322 aproximated number of toggles (32%), for which we know still have routers in the source code after week 49. Despite survival times between routers and points are statistically similar, routers do tend to live longer than points: at week 49, 50% of the routers remained in the code. After all, how useful is a toggle without points?
