clear;clc;close all;
%plots the filtered shocks across all models
%for output gap and inflation shocks--AR(1) processes
%for monetary policy, iid shocks

load estimation_results_mode; 
load shocks_filtered_var1_4regime.mat;
load shocks_filtered_ar1_4regime.mat;
load shocks_rise.mat;

startDate=datenum('01-06-1982');
endDate = datenum('01-12-2019');
Date=linspace(startDate,endDate,length(dataset_info.rawdata)-1);

figure('Name','Shocks');
subplot(3,4,1);
plot(Date,oo_.SmoothedVariables.u_y(2:end),'color','black');
xlim([startDate endDate])
datetick('x','yy','keeplimits');
title('REE');
ylim([-1 1]);
ylabel('\epsilon_y','FontSize',16);

subplot(3,4,5);
plot(Date,oo_.SmoothedVariables.u_pi(2:end),'color','black');
xlim([startDate endDate])
datetick('x','yy','keeplimits');
% title('REE, pi');
ylim([-0.25 0.25]);
ylabel('\epsilon_{\pi}','FontSize',16);

subplot(3,4,9);
plot(Date,oo_.SmoothedShocks.eps_r(2:end),'color','black');
xlim([startDate endDate])
datetick('x','yy','keeplimits');
% title('REE, r');
ylim([-0.4 0.4]);
ylabel('\eta_r','FontSize',16);

subplot(3,4,2);
plot(Date,shocks_rise_ar1(2:end,1),'color','black');
xlim([startDate endDate])
datetick('x','yy','keeplimits');
title('RISE');
ylim([-1 1]);

subplot(3,4,6);
plot(Date,shocks_rise_ar1(2:end,2),'color','black');
xlim([startDate endDate])
datetick('x','yy','keeplimits');
% title('RISE, pi');
ylim([-0.25 0.25]);

subplot(3,4,10);
plot(Date,shocks_rise(2:end,3)*0.127,'color','black');%this needs to be normalized by its standard deviation
xlim([startDate endDate])
datetick('x','yy','keeplimits');
% title('RISE, r');
ylim([-0.4 0.4]);


subplot(3,4,3);
plot(Date,S_filtered_var1_4regime(2:end,4),'color','black');
xlim([startDate endDate])
datetick('x','yy','keeplimits');
title('VAR(1)');
ylim([-1 1]);

subplot(3,4,7);
plot(Date,S_filtered_var1_4regime(2:end,5),'color','black');
xlim([startDate endDate])
datetick('x','yy','keeplimits');
% title('VAR1-4 regime, pi');
ylim([-0.25 0.25]);

subplot(3,4,11);
plot(Date,shocks_filtered_var1_4regime(3,2:end),'color','black');
xlim([startDate endDate])
datetick('x','yy','keeplimits');
% title('VAR1-4 regime, r');
ylim([-0.4 0.4]);


subplot(3,4,4);
plot(Date,S_filtered_ar1_4regime(2:end,4),'color','black');
xlim([startDate endDate])
datetick('x','yy','keeplimits');
title('AR(1)');
ylim([-1 1]);

subplot(3,4,8);
plot(Date,S_filtered_ar1_4regime(2:end,5),'color','black');
xlim([startDate endDate])
datetick('x','yy','keeplimits');
% title('AR1-4 regime, pi');
ylim([-0.25 0.25]);

subplot(3,4,12);
plot(Date,shocks_filtered_ar1_4regime(3,2:end),'color','black');
xlim([startDate endDate])
datetick('x','yy','keeplimits');
% title('AR1-4 regime, r');
ylim([-0.4 0.4]);

generate_figures('filtered_shocks_all','figures'); 