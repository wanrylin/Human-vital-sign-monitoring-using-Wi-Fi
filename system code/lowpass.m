function output = lowpass(input,Wp,Ws,fk)
% lowpass butterworth filter
% input:subcarrier matrix 
% Wp: pass cut-off frequence 
% Ws: block cut-off frequence 
% fk: sample rate(200)
p=Wp/(0.5*fk);
b=Ws/(0.5*fk);
[g,Wn]=buttord(p,b,1,30);
[b,a]=butter(g,Wn);
[l,w]=size(input);
output=[];
for i=1:w
    subcarrier=input(:,i);
    if all(subcarrier==0)
        continue
    end
    sub_filted=filter(b,a,subcarrier);
    output=[output,sub_filted];
end
end

