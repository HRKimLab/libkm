# libpopulation

### The data handling strategy

the results are saved in a text file at the single-session analysis procedure, and later when I do population analysis, I load all and made a big table. 
- Results can be saved in different files for each animal and analysis. 
- The first column of individual result file should be 'unitname', which is a key identifier to combine different tables.
- the unitname follows the format 'mNsNrNeNuN', which indicates the subject, session and, run number of the experiment. The next two is reserved for neural data. For example, e can be tetrode number and u can be a unit id for single units. As long as you use a 5-digit numertic format, the program does not care the meaning of it. It is just a key.

### Store analysis results in a one-line text format in the per-session analysis
```
data_header = {'CELL', 'MEAN_GROUP_1', 'MEAN_GROUP_2','SEM_GROUP_1', 'SEM_GROUP_2', 'P_DIFF'};
results = [2.4 5.2 0.2 0.3 0.03];
StoreResults(folder, text_filename, [], 'm281s18r1', data_header, results);
```
### Load and make a big table

### Perform basic population analysis
