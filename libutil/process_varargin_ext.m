function [leftoverV leftoverIdx] = process_varargin(V)

% leftoverV = process_varargin(V)
%
%  INPUTS
%     V - varargin cell array
% 
%  OUTPUTS
%     leftoverV - varargins not processed
%
%   expects varargin to consist of sequences of 'variable', value
%   sets variable to value for each pair.
%   changes the current workspace!
%   
%   Now only processes variables that already exist in the parent workspace
%
%
% ADR 2011
% modified by HRK 2020
leftoverV = {}; 
leftoverIdx = [];
for iV = 1:2:length(V)
	
% 	if evalin('caller',['exist(''', V{iV}, ''',''var'' )'])
    if isstr(V{iV}) && evalin('caller',['exist(''', V{iV}, ''',''var'' )']) % HRK 2020
		assignin('caller', V{iV}, V{iV+1});
    elseif iV + 1 <= length(V)
		leftoverV = cat(1, leftoverV, V(iV), V(iV+1));
        leftoverIdx = [leftoverIdx iV iV+1];
    else
        leftoverV = cat(1, leftoverV, V(iV));
        leftoverIdx = [leftoverIdx iV];
	end
		
end