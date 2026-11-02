clear;
clc;
clear all;
%%
eta_max=36.8;
k=0.1;
y=0:0.1:eta_max;
u_y=zeros(1,length(y));
A=[1,4,5;NaN,2,5;2,NaN,6];
for m=1:length(y)
    sum=0;
    for i=1:3
        for j=1:3
            a=A(i,j);
            if isnan(a)
                a=1;
            end
            sum = sum + a.*cos(j*k*y(m));
        end
    end
    u_y(m)=sum;
end
plot(u_y,y);
xlabel('u_y');
ylabel('y');
title('Plot of u_y vs y');
grid on;