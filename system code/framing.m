function [output] = framing(csi,sequence,frame_length,frame_interval)
%framing
%   sequence: the index of original data
rate=200;%sampling rate is 200Hz
[num_s,~]=size(csi);%number of sample, number of subcarriers
num_f=round((num_s-frame_length*rate)/(rate*frame_interval));%number of frame
i=1;
sequence=sequence+1;% the index is from 1 to 4096
[~,locs] = findpeaks(sequence);% find the start and end of the circulation
locs = [0;locs;length(sequence)]';%the first circulation is beginning from 0
num_matrix = length(locs)-1;% the number of circulation.
sequence_index=[];
%for every circulation
for num = 1:num_matrix
    matrix=sequence((locs(num)+1):locs(num+1));%sequence matrix every 4096
    index_matrix=4096*(num-1)+matrix-sequence(1)+1;% the index of them consecutive
    sequence_index=cat(2,sequence_index,index_matrix');
end
    for n= 1:(num_f+1)
        %produce frame
        if n ~= (num_f+1)
            frame=csi((n-1)*(frame_interval*rate)+1:(n-1)*(frame_interval*rate)+frame_length*rate,:);
        else
            frame=csi((n-1)*(frame_interval*rate)+1:end,:);
        end
        %judge the original data content
        index=find(sequence_index>=((n-1)*(frame_interval*rate)+1) & sequence_index<=(n-1)*(frame_interval*rate)+frame_length*rate);
        num_ori=length(index);
        if num_ori/(frame_length*rate) > 0.75
            output{i}=frame;
            i=i+1;
        end
    end
end