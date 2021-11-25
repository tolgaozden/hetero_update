clear;clc;close all;
addpath('c:\users\tolga\OneDrive\desktop\forward_guidance_paper\optimization_routines');
load('init_H2.mat');
load param_init.mat;
seed=round(1000*rand);
%rng(800);
%  param_init=[0.04 0.8 1.2 0.027 2.7 1.26 0.46...
%      0.69 0.71 0.84 0.73 0.28 0.31 0.001 0.004 0.02 0.10 0.001];    
%param_init=[0.06 0.97 1.34 0.035 3.1 1.32 0.35 0.38 0.05 0.8 0.75 0.26 0.33 0.1 0.1 0.04 0.02 0.02 0.1 0.01];

%param_init=[0.24 0.65 1 0.0073 4.27 1.39 0.46 0.87 0.87 0.79 0.16 0.03 0.30 0.05 0.01 0.02 0.11 0.01];    
%parameters: [bar_y bar_pi bar_r1 kappa tau phi_pi phi_y rho_y rho_pi rho_r 
% eta_y eta_pi eta_r1 bar_r2 eta_r2 1-p_11 1-p_22 gain]
% init_H=eye(17);
para_names = {'pi_bar(1)','r_bar(2)','kappa(3)','tau(4)',...
    'phi_pi(5)','phi_y(6)','phi_dy(7)','rho_y(8)','rho_pi(9)','rho_r(10)',...
    'eta_y(11)','eta_pi(12)','eta_r(13)','iota_y(14)','iota_p(15)',...
    'r_bar_zlb(16)','eta_r_zlb(17)','1-p_11(18)','1-p_22(19)','gain_y(20)'};


param_lb=[0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]';
param_ub=[1e5 1e5 1 1e5 1e5 1e5 1e5 1 1 1 1e5 1e5 1e5 1 1 1e5 1e5 1 1 1]';

param_bounds = [param_lb,param_ub];


objective= @(param) likelihood(param,param_bounds);
 init_H4=nhess(@likelihood,param_init,param_bounds);init_H4=inv(init_H4);%init_H4=diag(diag(init_H4));
save init_H4.mat init_H4;

load init_H4.mat;
  [fh,x,gh,H,itct,fcount,retcodeh] = csminwel(objective,param_init',init_H4,[] ,10^(-3),9999);
% 
% options=optimset('Display','iter','PlotFcns',@optimplotfval,'MaxIter',500);
% [x fh]=fminsearch('likelihood',param_init,options);

% options_ = cmaes;
% options_.SaveFilename = 'estimation_results_cmaes.mat';
%options_.Seed = '1903';
% options_.EvalParallel='yes';
% [x fh]=cmaes('likelihood',param_init',0.01*ones(24,1));
%0.1*ones(length(param_init),1)
laplace_=laplace_approximator(fh,x,H)

param_init=x;save param_init.mat param_init;
save estimation_results_march15.mat;

x=reshape(x,[length(x),1]);

table(para_names',x)


% index=1;
% for jj=1:10
% 
% if index==1
%     index=index-1;
%     try
%     [fh,x,gh,H,itct,fcount,retcodeh] = csminwel('likelihood',param_init',init_H4,[] ,10^(-5),9999);
%     init_H=H;save init_H.mat init_H;
%     param_init=x;save param_init.mat param_init;
%     catch
%     end
%     
%     
% else
%     
%  options=optimset('Display','iter','PlotFcns',@optimplotfval,'MaxIter',999);
% [x fh]=fminsearch('likelihood',param_init,options);
% param_init=x;save param_init.mat param_init;
% end
% 
% end