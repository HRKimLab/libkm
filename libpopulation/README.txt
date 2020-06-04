1. 
LoadPopulationDayaKey uses bottom-up search (dir all files in the directory and filter in with the criteria), whereas
LoadPopulationData uses top-down file search (find files meets the monk/cell criteria).
LoadTuningCueves also uses top-down file search. So the row # matches with the data loaded with LoadPopulationData, but not with LoadPopulationDataKey.

One caveat of top-down file search is it works well with single electrode, but become inefficient if it tries to search multiple electrode data becuase the 
memory space and file search combinations now become (monk #) * (cell #) * (electorde #). Therefore, it is better to have a bottom-up search version of LoadTuningCueves.
Hm.. an easy ways is to insert new unitkey if not found, and then just sort it out.

2. need to change LoadTuningCurve(Key) to load files the lastest file last (sorting flist by modified date).