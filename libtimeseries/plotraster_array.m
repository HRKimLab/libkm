function hP = plotraster_array(sTime, arData)
% imagesc binary array gives horrible visualization.
nTrial = size(arData, 1);
assert(length(sTime) == size(arData, 2), 'length(sTime) ~= size(arData,2)')
unique_signal = nonnan_unique(arData(:));
hP = [];
hold on;
% iterate trials
for iT=1:nTrial
    iStart = find( ~isnan(arData(iT, :)), 1, 'first');
    iEnd =   find( ~isnan(arData(iT, :)), 1, 'last');
    iEvent = find(arData(iT,:) > 0 );
    % plot
    h = plot(sTime(iEvent), ones(size(iEvent)) * iT, 'k.','markersize',2);
    if ~isempty(h)
        hP = [hP h];
    end
%     plot(sTime(iStart), ones(size(iStart)) * iT, 'v');
%     plot(sTime(iEnd)-1, ones(size(iEnd)) * iT, '^');
%     line(sTime([iStart iEnd]), ones(1,2) * iT, 
end
% draw t=0 line
line([0 0], [1 size(arData, 1)], 'color','k');
xlim(minmax(sTime)); ylim([1 nTrial+0.5]);
hold off;
axis ij
ylabel('Trial');
xlabel('Time (s)');
title(sprintf('# of trials = %d', nTrial));