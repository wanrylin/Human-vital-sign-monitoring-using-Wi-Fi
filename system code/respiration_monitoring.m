%% the final compilation of human respiration monitoring
% !!! attention using CSIdatapro function should install PricoScense MATLAB
% toolbox before runing new .csi file. Meanwhile the toolbox has updated
% for many version. The CSIdatapro function is already out of date and can
% not read data correctly !!!

% writer Wang_Ruilin@outlook.com
% this system aims to estimate the respiration rate of human via Wi-Fi CSI data
% In the system CSI amplitude and phase data is utilized to estimate vital
% sign respectively.
% 1 CSI data collection and optimizing
% 1.1 collect CSI data from the structure which is the output of the platform PicoScenes
[Rx1,Rx2,sequence]=CSIdatapro(Test,'hesu');
% Rx1 and Rx2 are the CSI data from antenna 1 and antenna 2
% sequence contains the index of the original data. Because the data in Rx1
% and Rx2 is after interpolation
% 1.2 make the data flow into frames in order to enhance the effiecency of the system
frame_length=10;
%every 5 seconds produce a new frame
frame_interval=5;
%sampling rate is 200Hz
rate=200;
%sampling rate
Rx1_amp_framed=framing(Rx1{1},sequence,frame_length,frame_interval);
Rx2_amp_framed=framing(Rx2{1},sequence,frame_length,frame_interval);
Rx1_pha_framed=framing(Rx1{2},sequence,frame_length,frame_interval);
Rx2_pha_framed=framing(Rx2{2},sequence,frame_length,frame_interval);
% divide the data flow into frame and select the credible frame
phase_diff=Rx1{2}-Rx2{2};
% utilize phase difference instead of amplitude or phase to reduce the
% influnce from thermal noise
pha_diff_framed=framing(phase_diff,sequence,frame_length,frame_interval);

%% estimate the vital sign under different method utilizing different csi data
% 5 kinds of CSI input
for input_mode = 5
    switch input_mode
%         case 1
%             csi_framed = Rx1_amp_framed;
%         case 2
%             csi_framed = Rx2_amp_framed;
%         case 3
%             csi_framed = Rx1_pha_framed;
%         case 4
%             csi_framed = Rx2_pha_framed;
        case 5
            csi_framed = pha_diff_framed;
    end
    num_frame = length(csi_framed);
    num_sub=10;
    selection_snr=1:num_sub;
    %initialization
    for n = 1:num_frame
        % 1.3 frame to reduce the data size and catch up with respiration rate change
        frame = csi_framed{n};
        % 2. subcarrier selection
        % 2.1 SNR-based subcarrier selection method
        selection_last_snr = selection_snr;
        [sub_selected_snr,selection_snr,snr_location,~]=subcarrier_selection_pro(frame,num_sub);
        %subcarrier selection via snr
        % the sub_selected_snr is already detrended
        if isempty(selection_snr)
            % if there is not any subcarriers is selected, utilizing last selection
            selection_snr=selection_last_snr;
            sub_selected_snr=frame(:,selection_snr);
            sub_selected_snr=detrend(sub_selected_snr);
            sub_selected_snr=hampel(sub_selected_snr);
            snr_location = location_capture(sub_selected_snr);
        end
        % 2.2 largest-variance subcarrier selection method
        [sub_selected_var,selection_var,var_location] = subcarrier_selection_var(frame);
        % 2.3 down sample
        sub_selected_snr = lowpass(sub_selected_snr,3,10,rate);
        sub_selected_var = lowpass(sub_selected_var,3,10,rate);
        [snr_sampled,snr_t_sampling] = down_sample(sub_selected_snr,rate,10);
        [var_sampled,var_t_sampling] = down_sample(sub_selected_var,rate,10);
        % 3. wavelet transform
        % 3.1 progressed wavelet transform
        snr_bre_db6 = wavelet_breathe(snr_sampled,'db6',snr_location);
        var_bre_db6 = wavelet_breathe(var_sampled,'db6',var_location);
        % 3.2 wavelet transform
        snr_bre_db4 = wavelet_breathe_pro(snr_sampled,'db4',1);
        % 4. respiration rate estimation
        figure();
        for res_mode = 1:3
            switch res_mode
                case 1
                    bre_wavelet = snr_bre_db6;
                    t_sampling = snr_t_sampling;
                case 2
                    bre_wavelet = var_bre_db6;
                    t_sampling = var_t_sampling;
                case 3
                    bre_wavelet = snr_bre_db4;
                    t_sampling = snr_t_sampling;
            end
            % 4.1 variance selection
            csiVar_bre = VarianceAnalysis(bre_wavelet,1);
            % 4.2 pca to combine the wave
            [coeff,score,latent] = pca(csiVar_bre);
            % Smooth
            avgsmooth=smooth(score(:,1),'rloess',50);
            % plot respiration wave
            subplot(3,1,res_mode);
            plot(t_sampling,avgsmooth);
            xlabel("time/s");
            ylabel("amplitude");
            switch res_mode
                case 1
                   title("SNR based subcarrier selection and Fast/Slow wavelet transform");
                case 2
                    title("Variance based subcarrier selection and Fast/Slow wavelet transform");
                case 3
                    title("SNR based subcarrier selection and traditional wavelet transform");
            end
            % respiration rate estimation
            respiratory_rate(n,res_mode) = respirationrate_estimation(avgsmooth,t_sampling,frame_length);
        end
    end
end
% the result
A_respiration{input_mode} = {respiratory_rate};
respiratory_rate(all(respiratory_rate==0,2),:)=[];
respiratory_rate=rmoutliers(respiratory_rate);
A_respiration_mean(:,input_mode) = mean(respiratory_rate)';
fprintf(['The estimated respiration rate is:',num2str(A_respiration_mean(1,5)),'Hz']);


