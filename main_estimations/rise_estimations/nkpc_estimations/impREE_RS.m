clear;clc;close all;
load nkpc_estimation_results_march15.mat;

%impREE_{regime_name}" #periods of IRFs x variable index x shock index 

myirfs0 = irf(mm,'irf_periods',100);

impREE_normal(:,1,1) = double(myirfs0.eps_y.gap_detrend2(:,1));
impREE_normal(:,1,2) = double(myirfs0.eps_pi.gap_detrend2(:,1));
impREE_normal(:,2,1) = double(myirfs0.eps_y.pinfobs(:,1));
impREE_normal(:,2,2) = double(myirfs0.eps_pi.pinfobs(:,1));

impREE_zlb(:,1,1) = double(myirfs0.eps_y.gap_detrend2(:,2));
impREE_zlb(:,1,2) = double(myirfs0.eps_pi.gap_detrend2(:,2));
impREE_zlb(:,2,1) = double(myirfs0.eps_y.pinfobs(:,2));
impREE_zlb(:,2,2) = double(myirfs0.eps_pi.pinfobs(:,2));


save impREE_rise impREE_normal impREE_zlb;

