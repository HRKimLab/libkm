# libpopulation

### The data handling strategy

the results are saved in a text file at the single-session analysis procedure, and later when I do population analysis, I load all and made a big table. 

### Store analysis results in a one-line text format during single-session analysis

data_header = {'CELL', 'MEAN_GROUP_1', 'MEAN_GROUP_2','SEM_GROUP_1', 'SEM_GROUP_2', 'P_DIFF'};
results = [2.4 5.2 0.2 0.3 0.03];
StoreResults(folder, text_filename, [], 'm281s18r1', data_header, results);

### Load and make a big table
