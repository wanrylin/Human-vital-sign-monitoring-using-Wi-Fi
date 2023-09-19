function num_person = multiperson(csi)
%multiperson determine whether there is more than one person under
%monitoring (only valid under IEEE 802.11ax protocols)
% input: csi phase
% output: num_person=0 only one person
%         num_person=1 more than one person
%         num_person=2 not ax protocols
[~,col]=size(csi);
num_sub=20;
% the number of selected subcarriers
num_person=2;
% initialization
if col > 244
    [csi_ssnr_pha,~,~,~]=subcarrier_selection_ssnr(csi,num_sub);
    % utilize ssnr subcarrier selection method select num_sub sensitive
    % subcarriers
    R=corrcoef(csi_ssnr_pha);
    % correlation coefficient
    R_mean=mean(R,'all');
    if R_mean > 0.91
        % when the correlation coefficient is more than 0.96, we consider
        % there is only one person. normally, the R_mean is close to 1 over
        % 0.99. 
        num_person=0;
    else
        % the R_mean can differ as the num_sub varys when more than one
        % persons
        num_person=1;
    end
end
end