# libpopulation

### The framework

- You save the results of a analysis in a file (e.g., text file) during per-session analysis procedure.
- Analysis results can be saved in different files for each subject and analysis routine.
- For population analysis, you set subjects and results files of interests. The program seeks for individual files, and construct a big 2-dminsional table [# of elements * attributes of analysis].

### Details

- The first column of individual result file should be 'unitname', which is a key identifier to combine different tables.
- The unitname follows the format 'mNsNrNeNuN', which indicates the subject, session and, run number of the experiment. The next two is reserved for neural data. For example, e can be tetrode number and u can be a unit id for single units. As long as you use a 5-digit numertic format, the program does not care the meaning of it. It is just a key.
- When there are multiple results with the same unitname, always the last ones are loaded.
- The first five column of a big table is the five unitname key values.
- As in some Matlab functions, plotting functions in the toolbox treat NaNs as missing values and print out accordingly.

### Store analysis results in a one-line text format in the per-session analysis
```
data_header = {'CELL', 'MEAN_GROUP_1', 'MEAN_GROUP_2','SEM_GROUP_1', 'SEM_GROUP_2', 'P_DIFF'};
results = [2.4 5.2 0.2 0.3 0.03];
StoreResults(folder, text_filename, [], 'm281s18r1', data_header, results);
```
### Load and make a big table

### Perform basic population analysis