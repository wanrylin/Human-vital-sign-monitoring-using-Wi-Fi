function [output,selection,location,ssnr] = subcarrier_selection_ssnr(csi,amount)
%subcarrier_selection select better sensetive subcarriers
% csi: subcarrier amplitude matrix original one
%amount: the amount of selected subcarriers

%initialize selection register
location=zeros(1,amount);
% figure();
% plot(Rx1_amp(1:2000,1));
% %static signal power is considered as the average CSI amplitude, includeing
% %reflected signal and thermal noise
s_power=mean(csi,1);
% figure();
% plot(hampel(Rx1_amp(1:2000,1)));
% %The interference power is calculated as the difference before and after
% %filtering the CSI amplitude.
inter_power=abs(mean(csi-hampel(csi),1));
% % The maximum value of the difference between the CSI amplitude and the averaged amplitude within the observation
% % window indicates the dynamic power.
l=length(csi);
diff=csi-ones(l,1)*s_power;
d_power=max(diff,[],1);
% %SSNR (sensing-signal-to-noiseratio) is the ratio of dynamic power to the
% %sum of static reflect power and interference power and the thermal noise
ssnr=d_power./(abs(s_power)+inter_power);
[~,selection]=sortrows(ssnr','descend');
selection=selection(1:amount)';
ssnr=ssnr(1:amount);
% csi=detrend(csi);
csi=hampel(csi);
output=csi(:,selection);
%calculate location
[num_pkg,~]=size(csi);
fs=200;
N=2^(nextpow2(num_pkg)+2);
for i=1:amount
    out_detrend=detrend(output);
    subcarrier=out_detrend(:,i);
    fft_sub=fft(subcarrier,N);
    fftshift_sub=fftshift(fft_sub);
    % Spectrum symmetry.
    %     %test plot
    %     l=length(subcarrier);
    %     n=-l/2:l/2-1;
    %     f=n*200/l;
    %     plot(f,abs(fft_sub));
    %     axis([-1,1,-inf,inf]);
    %         f=Fs*(-N/2:(N/2-1))/N;
    %         plot(f,abs(fft_sub));
    %         axis([-1,1,-inf,inf]);
    %calculate the spectrum form 0 to 1Hz
    center=abs(fftshift_sub(floor(N/2-N/fs): ...
        floor(N/2+N/fs),:));
    % center: (vector) the energy of  center part (low frequency) of the
    % spectrum symmetry.
    % N/2-N/fs: from the -1Hz.
    % N/2+N/fs: to the 1Hz.
    centerp=center.^2;

    %calculate the location
    [pks,locs]=findpeaks(centerp);
    pk=sortrows([pks,locs],1,'descend');
    Hz0=(pk(1,2)+pk(2,2))/2;
    step=2/(length(centerp)-1);
    pk(:,2)=(pk(:,2)-Hz0).*step;
    location(i)=abs(pk(1,2));
end
end