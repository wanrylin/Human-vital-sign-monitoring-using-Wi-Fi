function [Rx1,Rx2,sequence] = CSIdatapro (oridata,format)
%this function is used to get CSI Mag or Phase data from PicoScenes
%document.Compared to CSIdata this function can output the CSI data on each
%Rx antenna respectively.
%writer Wang31 1142937225@qq.com
%
%oridata:PicoScenes sruct
%format:a string,including:'nonht','vht','ht','hesu','hemu'
%output: Rx1 and Rx2 are 1*2 cell--{amplitude,phase}
%% collect data from thousands of struct consumes a lot of time.
%%In order to save time, the function will save the new output evertime in
%%the folder.
%safe
if nargin ~= 2
    error('输入变量数量错误!')
end
foldername=inputname(1);
filename=format;
%find whether have the folder
n=exist(foldername);
switch n
    case 0  %not have
        mkdir(foldername);%build and enter the folder
        cd(foldername);
    case 7  %already have
        cd(foldername);
        if exist([filename,'-','Rx1','.mat'])==2 && exist([filename,'-','Rx2','.mat'])==2 %whether have saved the data
            Rx1=load([filename,'-','Rx1','.mat']).Rx1;
            Rx2=load([filename,'-','Rx2','.mat']).Rx2;
            sequence=load([filename,'-','sequence','.mat']).sequence;
            %return the existing data
            cd('..')
            return
        end
end
format=lower(format);%transfer into lowercase character
amplitude=[];%initialize output
phase=[];
sequence=[];
%find the format and get the parameter required data
switch format
    case 'nonht'
        for i=1:length(oridata)
            data=oridata{i};
            pocketformat=getfield(getfield(data,'RxSBasic'),'PacketFormat');
            switch pocketformat
                case 0
                    CSI_amplitude=getfield(getfield(data,'CSI'),'Mag');
                    CSI_phase=getfield(getfield(data,'CSI'),'Phase');
                    pocketnum = getfield(getfield(data,'StandardHeader'),'Sequence');
                    amplitude=cat(1,amplitude,CSI_amplitude);
                    phase=cat(1,phase,CSI_phase);
                    sequence=cat(1,sequence,pocketnum);
            end
        end
    case 'nt'
        for i=1:length(oridata)
            data=oridata{i};
            pocketformat=getfield(getfield(data,'RxSBasic'),'PacketFormat');
            switch pocketformat
                case 1
                    CSI_amplitude=getfield(getfield(data,'CSI'),'Mag');
                    CSI_phase=getfield(getfield(data,'CSI'),'Phase');
                    pocketnum = getfield(getfield(data,'StandardHeader'),'Sequence');
                    amplitude=cat(1,amplitude,CSI_amplitude);
                    phase=cat(1,phase,CSI_phase);
                    sequence=cat(1,sequence,pocketnum);
            end
        end
    case 'vht'
        for i=1:length(oridata)
            disp(['extractdata',num2str(i/length(oridata)*100),'%']);
            data=oridata{i};
            pocketformat=getfield(getfield(data,'RxSBasic'),'PacketFormat');
            switch pocketformat
                case 2
                    CSI_amplitude=getfield(getfield(data,'CSI'),'Mag');
                    CSI_phase=getfield(getfield(data,'CSI'),'Phase');
                    pocketnum = getfield(getfield(data,'StandardHeader'),'Sequence');
                    amplitude=cat(1,amplitude,CSI_amplitude);
                    phase=cat(1,phase,CSI_phase);
                    sequence=cat(1,sequence,pocketnum);
            end
        end
    case 'hesu'
        for i=1:length(oridata)
            disp(['extractdata',num2str(i/length(oridata)*100),'%']);
            data=oridata{i};
            pocketformat=getfield(getfield(data,'RxSBasic'),'PacketFormat');
            switch pocketformat
                case 3
                    CSI_amplitude=getfield(getfield(data,'CSI'),'Mag');
                    CSI_phase=getfield(getfield(data,'CSI'),'Phase');
                    pocketnum = getfield(getfield(data,'StandardHeader'),'Sequence');
                    amplitude=cat(1,amplitude,CSI_amplitude);
                    phase=cat(1,phase,CSI_phase);
                    sequence=cat(1,sequence,pocketnum);
            end
        end
    case 'hemu'
        for i=1:length(oridata)
            data=oridata{i};
            pocketformat=getfield(getfield(data,'RxSBasic'),'PacketFormat');
            switch pocketformat
                case 4
                    CSI_amplitude=getfield(getfield(data,'CSI'),'Mag');
                    CSI_phase=getfield(getfield(data,'CSI'),'Phase');
                    pocketnum = getfield(getfield(data,'StandardHeader'),'Sequence');
                    amplitude=cat(1,amplitude,CSI_amplitude);
                    phase=cat(1,phase,CSI_phase);
                    sequence=cat(1,sequence,pocketnum);
            end
        end
end
%safe
if isempty(amplitude)
    cd('..');
    error('无该格式的包!')
else
    %%%%%
    %interpolation
    %%%%%
    [row,col] = size(amplitude);
    % In PicoScense platform thesequence of package is form 0 to 4095 and
    % circulating.
    output_amp=[];%initialize output
    output_pha=[];
    sequence=single(sequence);%convert from uint to single
    [~,locs] = findpeaks(sequence);% find the start and end of the circulation
    locs = [0;locs;length(sequence)];%the first circulation is beginning from 0
    num_matrix = length(locs)-1;% the number of circulation.
    %for every circulation
    for num = 1:num_matrix
        matrix_amp=zeros(4096,col);%initialize csi container
        matrix_pha=zeros(4096,col);
        for i = (locs(num)+1):locs(num+1)
            matrix_amp(sequence(i)+1,:) = amplitude(i,:);
            matrix_pha(sequence(i)+1,:) = phase(i,:);
            %divide csi data by circulation
        end
        matrix_amp(all(matrix_amp==0,2),:)=[];%remove 0
        matrix_pha(all(matrix_pha==0,2),:)=[];
        matrix_amp_inter=[];%initialize interpolation container
        matrix_pha_inter=[];
        %for every column
        for n=1:col
            %interpolate in the position of 0 points
            intered_amp=interp1(1+sequence((locs(num)+1):locs(num+1)),matrix_amp(:,n),1:4096,'linear')';
            matrix_amp_inter=cat(2,matrix_amp_inter,intered_amp);%conjunction
            intered_pha=interp1(1+sequence((locs(num)+1):locs(num+1)),matrix_pha(:,n),1:4096,'linear')';
            matrix_pha_inter=cat(2,matrix_pha_inter,intered_pha);
        end
        matrix_amp_inter(any(isnan(matrix_amp_inter),2),:)=[];%remove NaN
        matrix_pha_inter(any(isnan(matrix_pha_inter),2),:)=[];
        output_amp=cat(1,output_amp,matrix_amp_inter);
        output_pha=cat(1,output_pha,matrix_pha_inter);
        disp(['interpolation',num2str(num/num_matrix*100),'%']);
    end
%save
    l=size(output_amp,2);
    Rx1={output_amp(:,1:0.5*l),output_pha(:,1:0.5*l)};
    Rx2={output_amp(:,1+0.5*l:end),output_pha(:,1+0.5*l:end)};
    save([filename,'-','Rx1'],'Rx1');
    save([filename,'-','Rx2'],'Rx2');%save the data
    save([filename,'-','sequence'],'sequence');
end
cd('..');
end
