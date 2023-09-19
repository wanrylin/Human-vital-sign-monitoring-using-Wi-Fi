%% the final compilation of human vital sign monitoring
% !!! attention using CSIdatapro function should install PricoScense MATLAB
% toolbox before runing new .csi file. Meanwhile the toolbox has updated
% for many version. The CSIdatapro function is already out of date and can
% not read data correctly !!!

% writer Wang_Ruilin@outlook.com
% this system aims to estimate the heartrate and respiration rate of human
% via Wi-Fi CSI data
% In the system CSI amplitude and phase data is utilized to estimate vital
% sign respectively.

% 1. collect CSI data from the structure which is the output of the
% platform PicoScenes
[Rx1,Rx2,sequence]=CSIdatapro(Test,'hesu');
% Rx1 and Rx2 are the CSI data from antenna 1 and antenna 2
% sequence contains the index of the original data. Because the data in Rx1
% and Rx2 is after interpolation

% 2. make the data flow into frames in order to enhance the effiecency of
% the system
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
for input_mode = 1:5
    switch input_mode
        case 1
            csi_framed = Rx1_amp_framed;
        case 2
            csi_framed = Rx2_amp_framed;
        case 3
            csi_framed = Rx1_pha_framed;
        case 4
            csi_framed = Rx2_pha_framed;
        case 5
            csi_framed = pha_diff_framed;
    end

    num_frame = length(csi_framed);
    num_person=0;
    num_sub=10;
    selection_snr=1:num_sub;
    selection_ssnr=1:num_sub;
    multiperson_mode=0;
    %initialization

    for n = 1:num_frame
        frame = csi_framed{n};
        % 3. determine whether there are more than one person under monitering
        num_person_last=num_person;
        %last frame num_person value
        num_person=multiperson(Rx1_pha_framed{n});
        % num_person=0 only one person
        % num_person=1 more than one person
        % num_person=2 not ax protocols
        if num_person < 2
            multiperson_mode = num_person_last & num_person;
            % continous 2 frames are determined there are multi-person under monitoring
            % the system should be carried on under multiperson mode
        end

        % 4. subcarrier selection
        if multiperson_mode == 0
            % one person mode
            selection_last_snr = selection_snr;
            [sub_selected_snr,selection_snr,snr_location,~]=subcarrier_selection_pro(frame,num_sub);
            %subcarrier selection via snr the sub_selected_snr is already
            %detrended
            if isempty(selection_snr)
                % if there is not any subcarriers is selected, utilizing
                %  last selection
                selection_snr=selection_last_snr;
                sub_selected_snr=frame(:,selection_snr);
                sub_selected_snr=detrend(sub_selected_snr);
                sub_selected_snr=hampel(sub_selected_snr);
                snr_location = location_capture(sub_selected_snr);
            end
            selection_last_ssnr = selection_ssnr;
            [sub_selected_ssnr,selection_ssnr,ssnr_location,~]=subcarrier_selection_ssnr(frame,num_sub);
            %subcarrier selection via ssnr the sub_selected_ssnr has not
            %been detrended
            if isempty(selection_ssnr)
                % if there is not any subcarriers is selected, utilizing
                %  last selection
                selection_ssnr=selection_last_ssnr;
                sub_selected_ssnr=frame(:,selection_ssnr);
                sub_selected_ssnr=hampel(sub_selected_ssnr);
                ssnr_location = location_capture(sub_selected_ssnr);
            end
            sub_selected_ssnr=detrend(sub_selected_ssnr);
            %detrend sub_selected_ssnr

            % 5. down sample
            sub_selected_snr = lowpass(sub_selected_snr,3,10,rate);
            sub_selected_ssnr = lowpass(sub_selected_ssnr,3,10,rate);
            [snr_sampled,snr_t_sampling] = down_sample(sub_selected_snr,rate,10);
            [ssnr_sampled,ssnr_t_sampling] = down_sample(sub_selected_ssnr,rate,10);

            % 6. wavelet transform
            % utilizing db4 and snr subcarrier selection
            snr_bre_db4 = wavelet_breathe_pro(snr_sampled,'db4',1);
            snr_heart_db4 = wavelet_breathe_pro(snr_sampled,'db4',2);
            % utilizing db4 and ssnr subcarrier selection
            ssnr_bre_db4 = wavelet_breathe_pro(ssnr_sampled,'db4',1);
            ssnr_heart_db4 = wavelet_breathe_pro(ssnr_sampled,'db4',2);
            % utilizing db6 and snr subcarrier selection
            snr_bre_db6 = wavelet_breathe(snr_sampled,'db6',snr_location);
            % utilizing db6 and ssnr subcarrier selection
            ssnr_bre_db6 = wavelet_breathe(ssnr_sampled,'db6',ssnr_location);

            % 7. vital sign estimation
            % 7.1 respiration rate estimation
            for res_mode = 1:4
                switch res_mode
                    case 1
                        bre_wavelet = snr_bre_db4;
                        t_sampling = snr_t_sampling;
                    case 2
                        bre_wavelet = ssnr_bre_db4;
                        t_sampling = ssnr_t_sampling;
                    case 3
                        bre_wavelet = snr_bre_db6;
                        t_sampling = snr_t_sampling;
                    case 4
                        bre_wavelet = ssnr_bre_db6;
                        t_sampling = ssnr_t_sampling;
                end
                csiVar_bre = VarianceAnalysis(bre_wavelet,1);
%                 figure();
%                 plot(t_sampling,csiVar_bre);
                % variance selection

                [coeff,score,latent] = pca(csiVar_bre);
                % pca to combine the wave

                % Smooth
                avgsmooth=smooth(score(:,1),'rloess',50);

%                 figure();
%                 plot(t_sampling,avgsmooth);

                % respiration rate estimation
                respiratory_rate(n,res_mode) = respirationrate_estimation(avgsmooth,t_sampling,frame_length);
            end

            % 7.2 heart rate estimation
            csiVar_heart_snr = VarianceAnalysis(snr_heart_db4,1);
            [avgheart(n,1),heavist_heart(n,1),~]=heartrate_estimation(csiVar_heart_snr);
            csiVar_heart_ssnr = VarianceAnalysis(ssnr_heart_db4,1);
            [avgheart(n,2),heavist_heart(n,2),~]=heartrate_estimation(csiVar_heart_ssnr);
        end
    end

    % the result
    A_respiration{input_mode} = {respiratory_rate};
    respiratory_rate(all(respiratory_rate==0,2),:)=[];
    respiratory_rate=rmoutliers(respiratory_rate);
    A_respiration_mean(:,input_mode) = mean(respiratory_rate)';
    A_heartrate{input_mode} = {avgheart,heavist_heart};
    avgheart(all(avgheart==0,2),:)=[];
    avgheart = rmoutliers(avgheart,'quartiles');
    heavist_heart(all(heavist_heart==0,2),:)=[];
    heavist_heart = rmoutliers(heavist_heart,'quartiles');
    A_heartrate_mean(:,input_mode) = [mean(avgheart),mean(heavist_heart)]';
    % All the result is shown in the workspace with the matrics begining by
    % A. 
    % for example, A_respiration contains 5 cells and each cell contains
    % the result of 1 kind of mode, e.g.rx1 amplitude as input. In each
    % cell, there is a n*4 matrix which 4 columns indicates (snr,db4),
    % (ssnr,db4), (snr,db6), (ssnr,db6) and n rows indicates n frames.
    % A_respiration_mean shows the average value of the result.
    % A_heartrate_mean shows the average value of the result. The 4 rows
    % indicate (avg,snr), (avg,ssnr), (heavist,snr), (heavist,ssnr) methods
    % and 5 columns indicate 5 modes.

end
