clear;clc;%close all;
load us_dataset;


RR_tt=eye(3);
RR_tt1=eye(3);
phi_tt=zeros(3,2);
phi_tt1=zeros(3,2);
gg=0.01;
data=[pinfobs robs]';
data=data(:,120:end);
N=length(data);

for jj=2:N
regressand=data(:,jj)';
regressor=[1;data(:,jj-1)];

RR_tt = RR_tt1 + gg*(regressor*regressor'-RR_tt1);

phi_tt=phi_tt1 + gg*RR_tt^(-1)*regressor*(regressand - regressor'*phi_tt1); 

phi_tt1=phi_tt;
% phi_tt=phi_tt' 

RR(:,:,jj)=RR_tt;
PHI(:,:,jj)=phi_tt;
end


figure;
subplot(3,2,1);
plot(squeeze(PHI(1,1,2:end)));
subplot(3,2,2);
plot(squeeze(PHI(2,1,2:end)));
subplot(3,2,3);
plot(squeeze(PHI(3,1,2:end)));

subplot(3,2,4);
plot(squeeze(PHI(1,2,2:end)));
subplot(3,2,5);
plot(squeeze(PHI(2,2,2:end)));
subplot(3,2,6);
plot(squeeze(PHI(3,2,2:end)));



figure;
subplot(2,2,1);
plot(squeeze(RR(1,1,2:end)));
subplot(2,2,2);
plot(squeeze(RR(1,2,2:end)));
subplot(2,2,3);
plot(squeeze(RR(2,1,2:end)));
subplot(2,2,4);
plot(squeeze(RR(2,2,2:end)));
