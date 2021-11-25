clear;clc;%close all;
load us_dataset;


RR_tt=eye(2);
RR_tt1=eye(2);
phi_tt=[0.7 0.35 0.35; 0.5 0.33 0.85];
phi_tt1=[0.7 0.35 0.35; 0.5 0.33 0.85];
gg=0.05;
data=[pinfobs robs]';
data=data(:,44:end);
N=length(data);

for jj=2:N
Y_tt=data(:,jj);
X_tt=[1;data(:,jj-1)];

RR_tt = RR_tt1 + gg*(Y_tt*Y_tt'-RR_tt1);

phi_tt=phi_tt1 + gg*RR_tt^(-1)*Y_tt*(X_tt - phi_tt1'*Y_tt)'; 

phi_tt1=phi_tt;
phi_tt=phi_tt';

RR(:,:,jj)=RR_tt;
PHI(:,:,jj)=phi_tt';
end




figure;
subplot(2,3,1);
plot(squeeze(PHI(1,1,2:end)));
subplot(2,3,2);
plot(squeeze(PHI(1,2,2:end)));
subplot(2,3,3);
plot(squeeze(PHI(1,3,2:end)));

subplot(2,3,4);
plot(squeeze(PHI(2,1,2:end)));
subplot(2,3,5);
plot(squeeze(PHI(2,2,2:end)));
subplot(2,3,6);
plot(squeeze(PHI(2,3,2:end)));


figure;
subplot(2,2,1);
plot(squeeze(RR(1,1,2:end)));
subplot(2,2,2);
plot(squeeze(RR(1,2,2:end)));
subplot(2,2,3);
plot(squeeze(RR(2,1,2:end)));
subplot(2,2,4);
plot(squeeze(RR(2,2,2:end)));
