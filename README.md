# PER_GGV_GriffinTireEdition
PER's GGV. Acquired by Griffin (suspension) from Chris Zhang (VD) sometime during COVID from separate repository for PER's GGV. Has been modified for tire graph generation.


To generate tire graphs based upon FSAE TTC data:
1. Open matlab.
2. Make Vehicle-Dyanmics-Master the project folder by selecting "Browse for folder" (for new project).
3. Expand model_sim folder to see contents in dropdown (cause this is where basically everything happens).
4. Run startup.m.
5. Navigate to study>handling>tire_coefficient_fit.
6. Click on (open) either tcf16lat.m for lateral graphs or tcf18long.m for longitudinal graphs (16 and 18 initially denoted tire ODs, but I believe the code does not care about tire OD).
7. In either of those two docs, type the round # next to "round = " for the round that your desired data is in, and type the first and last run #s next to "run = " and "runs = ", respectively.
i.e. I want to generate graphs for round 6 runs 23 through 26 would be "round = 6; run = 23; runs = 26;".

8. (optional) change graph title and axis labels towards the bottom of tcf16lat.m and tcf18long.m if need be.
9. Click run to generate graphs into popup windows.

Note: when opening or running startup.m or tcf.....m its possible that a window will come up saying its not found on path. Click add to path and proceed as normal and everything should work.

Note 2: also might need to change saveas path in tcf.....m if you want to automatically save pngs of graphs.