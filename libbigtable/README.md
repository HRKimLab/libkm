# libbigtable

libbigtable loads numeric data distributed in different files, combine the results into one big 2D array, where rows are individual entities and columns are different features. It checkes the ID of each entity and load the last results and overwrite the current eneity with the latest eneity. You keep appending your analysis results to the files without manually organizing the results. It stuffs unloaded data with NaNs. This big table then goes well with [libpopulation](https://github.com/hkim09/libkm/tree/master/libpopulation/). Note that the loading function works based on some assumptions (see  below). You may need to change the way you save the analysis results. 

See demo_save_results_load_bigtable.m

# What you can do

- construct a fast and efficient analysis pipeline from individual analysis and population analysis

### The framework

- You save the results of a analysis in a file (e.g., text file) during per-session analysis procedure.
- Analysis results can be saved in different files for each subject and analysis routine.
- For population analysis, you set subjects and results files of interests. The program seeks for individual files, and construct a big 2-dminsional table [# of elements * attributes of analysis].
- Once the big table is loaded, you set various flags to dissect the data, and play with it!

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
StoreResults('Z:\Data\Analysis\281\', 'beh_outcome.dat', [], 'm281s18r1', data_header, results);
```
### Load and make a big table
```
% set data root
DATA_ROOT = ['Z:\Data' filesep];
% assign subject and session
% all batch
MonkOfInterest = [281 282 283];          % subject numbers
CellOfInterest = {1:100, 1:100, 1:100};  % inclusive session numbers.

% initialize essential variables
ResultsExt={}; ResultsHeader={};
nResults = 0; ResultsMultipleDelims=[];

% An example registring result files to the big table. You can keep adding result files.
nResults = nResults + 1;
ResultsExt{nResults} = 'beh_';         % identifier for this result file
ResultsHeader{nResults} = {'CELL', 'MEAN_GROUP_1', 'MEAN_GROUP_2','SEM_GROUP_1', 'SEM_GROUP_2', 'P_DIFF'};
ResultsSummary{nResults} = 'beh_outcome.dat'
ResultsMultipleDelims(nResults) = 0;

% load the data into aPD 2D array. 
LoadPopulationData5Key;

% for example, the first column of the above result can be accessed via colunm name variable beh_MEAN_GROUP_1
hist( aPD(:, beh_MEAN_GROUP_1) )
```
### Perform basic population analysis

Now, individual features of the data can be accessed by a column vector indexed from aPD table. [libpopulation](https://github.com/hkim09/libkm/edit/master/libpopulation/)  has a variety of basic plotting functions that works well with data in a column vector shape.
