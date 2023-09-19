function respiratory_rate = respirationrate_estimation(input,t_sampling,frame_length)
% respirationrate_estimation
input=input./(max(input)-min(input));
[~,~,~,hight] = findpeaks(input,'MinPeakWidth',10);
[pks_peak, locs_peak] = findpeaks(input,t_sampling,'MinPeakProminence',0.2*median(hight),'Annotate','extents');
[pks_valley, locs_valley] = findpeaks(-1.*input,t_sampling,'MinPeakProminence',0.2*median(hight),'Annotate','extents');
%if there is 2 breaths in 1 frame
if length(pks_peak) >= 2 && length(pks_valley) >= 2
    % no less than 2 times
    %combine location of peaks and valleys
    locs=[locs_peak(1:min([length(locs_peak),length(locs_valley)]));locs_valley(1:min([length(locs_peak),length(locs_valley)]))];
    %find the difference time of the adjacent peak and valley, which is
    %half of the duration
    Interval = abs(diff(locs,1,1));
    respiratory_duration = mean(Interval);
    respiratory_rate = 0.5/respiratory_duration;
else
    % less than 2 times
    % mirror the avgsmmoth twice  
    breath_wave=[fliplr(input')';input;fliplr(input')'];
%     figure();
%     plot(breath_wave);
    % 3 times longer and then findpeaks
    % make man-made duration to hlep findpeaks
    [~,~,~,hight] = findpeaks(breath_wave,'MinPeakWidth',10);
    pks = findpeaks(breath_wave,'MinPeakProminence',0.2*median(hight),'Annotate','extents');
    vals = findpeaks(-1.*breath_wave,'MinPeakProminence',0.2*median(hight),'Annotate','extents');
    breath_times=(length(pks)+length(vals))/6;
    respiratory_rate=breath_times/frame_length;
end
end