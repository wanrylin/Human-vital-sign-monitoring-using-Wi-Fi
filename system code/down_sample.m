function [data_downsample,t_downsample] = down_sample (ori_data,ori_samplingrate,sample_times)
% this is used to downsample the CSI data.
% 
% ori_data: the raw CSI before downsample. It can be Matrix. Make sure that
% each row is each subcarries and each col is each time moment.
% ori_sampling_rate: the sampling rate before downsample.
% sample_times: the ratio between sampling rates before and after
% downsample.
% data_downsample: the CSI after downsample.
% t_downsample: the t scale after downsample.

[num_t,num_subcarries] = size(ori_data);

data_downsample = [];

t_downsample = (1:fix(num_t/sample_times))./ori_samplingrate.*sample_times;

for n = 1:num_subcarries
    for i=1:fix(num_t/sample_times)
    data_downsample(i,n)=mean(ori_data((i-1)*sample_times+1:i*sample_times,n));
    end   
end



