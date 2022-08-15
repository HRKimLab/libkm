function plot_TCN(pc_score, varargin)

grp_label = ''
animation = 1;
sampling_rate = 100;

process_varargin(varargin)

nTime = size(pc_score, 1);

plot(pc_score(:, :, 1), pc_score(:, :, 2) );
xlabel('PC1');ylabel('PC2');
hold on;
% mark start
plot(pc_score(1, :, 1), pc_score(1, :, 2), 'ko');
% mark end
plot(pc_score(end, :, 1), pc_score(end, :, 2),'kx');
% mark traveler 
hTraveler = plot(pc_score(end, :, 1), pc_score(end, :, 2),'kv');
set(hTraveler,'tag','traveler2D');
hTitle = title('0s');
if animation
    % travel trajectory
    inc_time = round(nTime/500);
    if inc_time < 1, inc_time = 1; end
    
    for iTime = 1:inc_time :nTime
        set(hTraveler,'XData', pc_score(iTime, :, 1), 'YData', pc_score(iTime, :, 2) );
        set(hTitle, 'string', sprintf('%.1fs', iTime/sampling_rate));
        drawnow;
        pause(0.01);
    end
end

function travel_3D(src,event)
    hTraveler3 = findobj(gcf,'tag','traveler3D');
    % retrieve saved data
    dt = get(src,'UserData');
    hTitle = title(dt.ax,'');
    for iTime = 1:round(nTime/500):nTime
        set(hTraveler3,'XData', dt.pc_score(iTime, :, 1), 'YData', dt.pc_score(iTime, :, 2), 'ZData',  dt.pc_score(iTime, :, 3));
        set(hTitle, 'string', sprintf('%.1fs', iTime/sampling_rate) );
        drawnow;
        pause(0.01);
    end 
end

end