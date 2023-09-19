function csiVar = VarianceAnalysis(input,dim)
% this function is used to remove different sets of subcarriers that is
% waveleted.
% input: the data from upstream
% dim: 1 = col
variances=var(input,0,dim);
% calculate the variances on the dim (col or row)
var_var=var(variances);
% calculate the variance of variances to see if they are similar.
csiVar = input;
if var_var > 3
    avg_var = mean(variances);
    keep = find(variances > avg_var);
    csiVar = input(:,keep);
    % remove the subcarriers that have less var. This step can leave only
    % one type of subcarriers.
end
