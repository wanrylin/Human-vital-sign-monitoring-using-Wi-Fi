function [average,heavist,location] = heartrate_estimation(input)
% heartrate_estimation
% 
% figure();
% plot(1:200,input);
[row,col] = size(input);
Fs=20;
location=[];
snr=[];

for i=1:col
        sub=input(:,i);%extract the subcarrier
        num_pkg=row;%the number of point
        N=2^(nextpow2(num_pkg)+4);%fft point 
        f=Fs*(-N/2:(N/2-1))/N;% frequency
        fft_sub=fft(sub,N);% fft
        fftshift_sub=abs(fftshift(fft_sub));
%         figure();
%         plot(f,fftshift_sub);
        avg=mean(fftshift_sub);% average power
        [pks,locs]=max(fftshift_sub);% find the strongest component
        location=[location,abs(f(locs))];%find the frequency of this component
        SNR=pks/avg;% calculate the snr of every subcarrier
        snr=[snr,SNR];
end
%average frequency
average=mean(location);
%the strongest subcarrier
[~,index]=max(snr);
heavist = location(index);
end