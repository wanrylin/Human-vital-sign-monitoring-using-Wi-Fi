function [location] = location_capture(input)
%location_capture find the location of peak

[num_pkg,num_subcarriers]=size(input);
fs=200;
N=2^(nextpow2(num_pkg)+2);
input=detrend(input);
location=zeros(1,num_subcarriers);

for i=1:num_subcarriers
    subcarrier=input(:,i);
    %             subcarrier=detrend(subcarrier); % delet DC
    fft_sub=fft(subcarrier,N);
    fftshift_sub=fftshift(fft_sub);
    center=abs(fftshift_sub(floor(N/2-0.6*N/fs): ...
        floor(N/2+0.6*N/fs),:));
    avg = mean(center);
    centerp=center.^2;
    SNR = centerp./avg^2;
    snr_max=max(SNR);
    [pks,locs]=findpeaks(centerp);
    pk=sortrows([pks,locs],1,'descend');
    Hz0=(pk(1,2)+pk(2,2))/2;
    step=fs/N;
    pk(:,2)=(pk(:,2)-Hz0).*step;
    location(i)=abs(pk(1,2));
end
end