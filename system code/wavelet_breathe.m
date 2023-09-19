function output = wavelet_breathe(input,wvname,location)
%wavelet_breathe_pro wavelet transform
%  input: original signal
[~,col]=size(input);
output=[];
order=6;
for i=1:col
    %CSI for one subcarrier
    CSI=input(:,i);
    [c,l]=wavedec(CSI,order,wvname);
    if abs(location(i)) > 0.3
        d_l=wrcoef('d',c,l,wvname,order-1);
        output=[output,d_l];
    else
        d_h = wrcoef('d',c,l,wvname,order);
        output=[output,d_h];
    end

end
end