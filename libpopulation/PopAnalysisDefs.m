% if ~isempty( which('Path_Defs')), Path_Defs; end;

% analysis directory for each monkey
ANALYSIS_DIR={};
ANALYSIS_DIR{9}='Z:\Data\MOOG\Barracuda\Analysis\';
ANALYSIS_DIR{15}='Z:\Data\MOOG\Ovid\Analysis\';
ANALYSIS_DIR{31}='Z:\Data\MOOG\Abbott\Analysis\';
ANALYSIS_DIR{32}='Z:\Data\MOOG\Chunky\Analysis\';
ANALYSIS_DIR{33}='Z:\Data\MOOG\Chiku\Analysis\';

% tuning curves directory for each monkey
TUNING_DIR={};
TUNING_DIR{9}='Z:\Data\MOOG\Barracuda\Analysis\Tuning\';
TUNING_DIR{15}='Z:\Data\MOOG\Ovid\Analysis\Tuning\';
TUNING_DIR{31}='Z:\Data\MOOG\Abbott\Analysis\Tuning\';
TUNING_DIR{32}='Z:\Data\MOOG\Chunky\Analysis\Tuning\';
TUNING_DIR{33}='Z:\Data\MOOG\Chiku\Analysis\Tuning\';

% raw data directory for each monkey
HTB_DIR={};
HTB_DIR{9}='Z:\Data\MOOG\Barracuda\Raw\';
HTB_DIR{15}='Z:\Data\MOOG\Ovid\Raw\';
HTB_DIR{31}='Z:\Data\MOOG\Abbott\Raw\';
HTB_DIR{32}='Z:\Data\MOOG\Chunky\Raw\';
HTB_DIR{33}='Z:\Data\MOOG\Chiku\Raw\';


% shape index for origin
SHAPE_IDX=[];
SHAPE_IDX(31,1) = 2;
SHAPE_IDX(32,1) = 3;
SHAPE_IDX(33,1) = 1;

MONK_NAME={};
MONK_NAME{31} = 'Abbott';
MONK_NAME{32} = 'Chunky';
MONK_NAME{33} = 'Chiku';