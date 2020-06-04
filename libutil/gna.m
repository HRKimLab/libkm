function [hP iP]=gna(axis_id)
global gP
% get next axis
% h = evalin('caller','figinfo.h');
% v = evalin('caller','figinfo.v');
% iP = evalin('caller','figinfo.iP');
h = gP.figinfo.h;
v = gP.figinfo.v;
iP = gP.figinfo.iP;

% bNewFig = evalin('caller','(isfield(figinfo,''bNew'') && figinfo.bNew)'); % generate new figure instead of subplot (for actual figures)
bNewFig = isfield(gP.figinfo, 'bNew') && gP.figinfo.bNew;

if is_arg('axis_id') && isnumeric(axis_id)
    assert(all( axis_id <= iP), 'axis_id should be incremental, or referring to existing axes');
    if  all(axis_id < iP)
        for iA=1:length(axis_id)
        hP(iA) = subplot(h,v,axis_id(iA));
        end
        return;
    end
end

if bNewFig && iP > 1
    hP = figure; 
elseif bNewFig && iP == 1
    hP = gcf;
end;

if iP > h * v
    error('too many axes (%d). increase h(%d),v(%d)', iP,h,v);
%     setfig(h,v);
end

if ~bNewFig, hP = subplot(h,v,iP); end;

% for auxiliary use
if is_arg('axis_id') && ischar(axis_id)
    % actually this strategy won't work. tag will be overwritten when new a new plot is drawn.
    set(hP, 'tag', axis_id); 
else
    set(hP, 'tag', 'plotaxes');
end

% convert to string doesn't work should use direct assign
% assignin('caller','tmp09',hP);
% evalin('caller',['figinfo.hP(figinfo.iP) = tmp09;']);
% evalin('caller','figinfo.iP = figinfo.iP + 1;');
gP.figinfo.hP(gP.figinfo.iP) = hP;
gP.figinfo.iP = gP.figinfo.iP + 1;