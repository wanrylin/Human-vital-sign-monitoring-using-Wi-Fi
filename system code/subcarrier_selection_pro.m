function [output,selection,location,snr] = subcarrier_selection_pro(input,amount)
%subcarrier_selection select better sensetive subcarriers
% input: subcarrier matrix
% threshold: the ratio between the peaks of different frequency components
% and the average.
%amount: the amount of selected subcarriers
% % input=detrend(input);
selection=zeros(1,amount);%initialize selection register
snr=zeros(1,amount);
location=zeros(1,amount);
[num_pkg,num_subcarriers]=size(input);
fs=200;
N=2^(nextpow2(num_pkg)+2);
input=detrend(input);
input=hampel(input);
for i=1:num_subcarriers
    subcarrier=input(:,i);
%             subcarrier=detrend(subcarrier); % delet DC
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
    %calculate the spectrum form 0 to 0.6Hz
    center=abs(fftshift_sub(floor(N/2-0.6*N/fs): ...
        floor(N/2+0.6*N/fs),:));
    % center: (vector) the energy of  center part (low frequency) of the
    % spectrum symmetry.
    % num_pkg/2: from the 0.
    % num_pkg/20: to the 1/20 of the whole spectrum.
    %calculate SNR
    avg = mean(center);
    centerp=center.^2;
    SNR = centerp./avg^2;
    snr_max=max(SNR);
    %calculate peaks and those locations
    [pks,locs]=findpeaks(centerp);
    pk=sortrows([pks,locs],1,'descend');
    Hz0=(pk(1,2)+pk(2,2))/2;
    step=fs/N;
    pk(:,2)=(pk(:,2)-Hz0).*step;
    max_pk=max(pks);
    pks(pks>=max_pk)=0;
    max2_pk=max(pks);
    % plot(centerp);
    %judge whether there is only one peak or not
    %we only select those subcarriers with one peak to reach less
    %interference
    if max_pk > max2_pk*2
        %compare the maxsnr of this subcarrier with existed mini snr
        [snr_min,loc_min]=min(snr);
        if snr_max > snr_min
            snr(loc_min)=snr_max;
            selection(loc_min)=i;
            location(loc_min)=abs(pk(1,2));
        end
    end
end
%remove 0
selection(find(selection==0))=[];
location(find(location==0))=[];
snr(find(snr==0))=[];
output=input(:,selection);
end

