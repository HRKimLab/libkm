function set_two_ticks(ax)
% leave only two ticks to simplfiy plots
% 2018 HRK
nA = numel(ax);
for iA = 1:nA
   yt = get(ax(iA), 'ytick');
   ytl = get(ax(iA), 'yticklabel');
   if numel(yt) > 2
       % yticklabel is character. just use ytick for label
%         set(ax(iA), 'ytick', [yt(1) yt(end)], 'yticklabel', ytl([1 end]));
            set(ax(iA), 'ytick', [yt(1) yt(end)], 'yticklabel', [yt(1) yt(end)]);
   end
end