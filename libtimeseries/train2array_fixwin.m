function [arAligned tTime] = train2array_fixwin(train, t_event, t_xlim)
% train2array_fixwin(train, t_event, t_xlim)
% convert a stream of data to an array of data aligned by events.
% t_event: column vector indicating events
% train: a stream of data [1 nTime]
% t_xlim: x tick range relative to t_event (e.g., [-100 1500])
% arAligned: [# of event *  time]

assert(length(t_xlim) == 2 && diff(t_xlim) > 0, 't_xlim should be two elemets with increasing order')

% generate index array
tTime = t_xlim(1):t_xlim(2);
[tmp_iRanges tmp_iEvent] = meshgrid(tTime, t_event);
iOnsetAligned = round(tmp_iRanges + tmp_iEvent);

% assign memory
arAligned = NaN(size(iOnsetAligned));

% stuff a train with NaN
if t_xlim(1) < 0, StuffBefore = NaN(1, -t_xlim(1)); else, StuffBefore = []; end;
if t_xlim(2) > 0, StuffAfter = NaN(1, t_xlim(2)); else; StuffAfter = []; end;

% generate stuff train
stuffed_train = [StuffBefore train StuffAfter];

% re-align onset based on stuffing
iOnsetAligned = iOnsetAligned + length(StuffBefore);

% generate an aligned output array
arAligned = stuffed_train(iOnsetAligned);