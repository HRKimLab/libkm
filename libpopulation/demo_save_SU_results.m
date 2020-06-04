% example of saving SU analysis resuts. Here I show how to save numerical results 
% into text file format. This part should be done in each analysis function 
% (e.g., the function called by TEMPO_GUI or BATCH_GUI)
% 3/15/2014 HRK.

PATHOUT = 'Z:\LabTools\Matlab\TEMPO_Analysis\CommonTools\PopLib\AnalysisData\';
SINGLE_FILES = 'm999c1r1.dir';
ACCUM_FILE = 'beh_analysis.dat';

% 1) One way to save single cell results is to save separate text file for each cell. 
% basic tuning results are currently saved in this way.
cHeader = {'PrefDir', 'MaxResp', 'TuningWidth'};
data =    [135, 80, 45];
SaveResults([PATHOUT SINGLE_FILES], [], cHeader, data);
% 2) Another way is to accumulate results in a single text file, but give a
% unitkey to identify the cell.
unitkey = 'm99c2r5';
cHeader = {'CELL', 'MonkThres', 'NeuronThres', 'dprime'};
data =    [24, 65, 1.34];
SaveResults([PATHOUT ACCUM_FILE], unitkey, cHeader, data, 1);