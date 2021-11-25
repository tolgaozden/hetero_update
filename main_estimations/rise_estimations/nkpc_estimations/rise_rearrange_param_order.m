clear;clc;close all;
load estimation_results_july6th_rise_MCMC.mat;
 
 Ndraws=250000;
 Nburn=100000;
 numVar=19;
 mode=x0;
 st_dev=sqrt(diag(SIG));
 
 logposterior=nan(Ndraws,1);
 posteriorDraws=nan(Ndraws,numVar);
 for jj=1:Ndraws;
     disp(jj)
     logposterior(jj)=-Results.pop(jj).f;
     posteriorDraws(jj,:)=Results.pop(jj).x;
     
 end;
 
% para_names = {'pi_bar(1)','r_bar(2)','kappa(3)','tau(4)',...
%     'phi_pi(5)','phi_y(6)','phi_dy(7)','rho_y(8)','rho_pi(9)','rho_r(10)',...
%     'eta_y(11)','eta_pi(12)','eta_r(13)','iota_y(14)','iota_p(15)',...
%     'r_bar_zlb(16)','eta_r_zlb(17)','1-p_11(18)','1-p_22(19)'};
%  
 
para_names = {'pi_bar','r_bar','kappa','tau',...
    'phi_pi','phi_y','phi_dy','rho_y','rho_pi','rho_r',...
    'eta_y','eta_pi','eta_r','iota_y','iota_p',...
    'r_bar_zlb','eta_r_zlb','1-p_11','1-p_22'};

rise_param_order=[3 4 5 6 7 8 9 10 11 14 15 16 17 12 13 18 19 1 2];
    


   
 %re-arrange for different order in RISE
%   names_rise=names_tex(rise_param_order);
 mode=mode(rise_param_order);
 st_dev=st_dev(rise_param_order);
 posteriorDraws=posteriorDraws(:,rise_param_order);
 