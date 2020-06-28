function fig_title(sTitle, font_size)

% pStartOffset = 0.2;
pStartOffset = 0.04;
if ~is_arg('font_size'), font_size = 12; end;
if ~is_arg('sTitle'), return; end;
% This is not necessary in the new landscape figure style
% if length(sTitle) > 45
%     pStartOffset = 0.01;
%     font_size = 11;
% end;

sTitle = regexprep(sTitle,'\\','/');
sTitle = regexprep(sTitle,'_','\\_');

set(gcf, 'name',sTitle);

% display title
ax = axes('Position', [0.0 .975 .9 .025]);
set(ax, 'tag', 'fig_title');
hT = text(pStartOffset, 0.5, sTitle, 'fontsize', font_size, ...
    'fontweight','bold', 'linestyle','none','tag','fig_title');
set(ax, 'visible','off','HandleVisibility','off');
% display data collection date
global data

% get data collection date from global data if possible
if isfield(data, 'one_time_params')
    RigInfo = '';
    switch(data.one_time_params.MachineName)
        case 'Mcb-Uchida-VS5'
            RigInfo = 'R1';
        case 'Mcb-UCHIDA-VS2'
            RigInfo = 'R2';
        case 'MCB-UCHIDA-VS6'
            RigInfo = 'R3';
        case 'Mcb-Uchida-VS4'
           RigInfo = 'R4';
    end
    dn = datenum(data.one_time_params.Datetime);
    sDate = [ datestr( dn, 'mm/DD') '@' RigInfo];
else
    sDate = ' ';
end

ax = axes('Position', [0.8 .975 .2 .025], 'tag', 'date');
% append analysis date
sDate = [sDate ' / DoA:' datestr(now(), 'mm/DD')];
text(pStartOffset, 0.6, sDate, 'fontsize', 8, ...
    'fontweight','bold', 'linestyle','none', 'tag','col_date');

% % analysis date
% sDate = ['Analyzed: ' datestr(now(), 'mm/DD')];
% text(pStartOffset, 0.0, sDate, 'fontsize', 8, ...
%     'fontweight','bold', 'linestyle','none', 'tag','anal_date');

% show the the analysis fuction filename for other people 
% such that they know what code to take a look at
callstack = dbstack;
func_name = [];
for iC=1:numel(callstack)
   switch(callstack(iC).name)
       case {'fig_title', 'create_figure','setfig','setpanel'} % skip these function names
       case {'LiveEditorEvaluationHelperESectionEval','evaluateCode'} % callbacks when evaluated in the editor
       otherwise
           func_name = callstack(iC).name;
           break;
   end
end
if ~isempty(func_name)
    func_name = regexprep(func_name,'_','\\_');
    text(pStartOffset, 0.0, func_name, 'fontsize', 8, ...
        'fontweight','bold', 'linestyle','none','tag','func_name');
end

% inactivate the axes to avoid plotting on this axes
set(ax, 'visible','off','HandleVisibility','off');