function output = wavelet_breathe_pro(input,wvname,type)
%wavelet_breathe_pro wavelet transform
%  input: original signal
%  type: 1-breath  2-heartrate
[~,col]=size(input);
output=[];
order=4;
for i=1:col
    %CSI for one subcarrier
    CSI=input(:,i);
    [c,l]=wavedec(CSI,order,wvname);
    switch type
        case 1
            %approximation coefficient
            A=wrcoef('a',c,l,wvname,order);
            output=[output,A];
        case 2
            %detail coefficient
            D_3=wrcoef('d',c,l,wvname,order-1);
            D_4=wrcoef('d',c,l,wvname,order);
            D=D_3+D_4;
            output=[output,D];
    end
end
end