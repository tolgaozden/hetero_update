clear;clc;%close all;
% load('estimation_results_march15.mat');
% load estimation_results_var1.mat;
load estimation_results_march15
% load param_init;
% parameters=param_init;

para_names = {'y_bar(1)','pi_bar(2)','r_bar(3)','kappa(4)','tau(5)',...
    'phi_pi(6)','phi_y(7)','rho_dy(8)','rho_y(9)','rho_pi(10)','rho_r(11)',...
    'eta_y(12)','eta_pi(13)','eta_r(14)','iota_y(15)','iota_p(16)',...
    'r_bar_zlb(17)','eta_r_zlb(18)','1-p_11(19)','1-p_22(20)','gain(21)'};
parameters=x;
THETA1=1;
THETA2=1;
PHI1=parameters(19)*100;
PHI2=parameters(20)*100;
memory=0.5;
intensity=1;
parameters(1)=0;
parameters(2)=0.4;
parameters(3)=0.7;
% parameters(2)=0.3;
r_bar1 = parameters(3);
r_bar2 = parameters(17);
pi_bar = parameters(2);
y_bar = parameters(1);

% parameters(7)=0.2;
parameters=vec(parameters);
table(para_names',parameters);





startDate=datenum('01-01-1966');
endDate = datenum('01-12-2016');
Date=linspace(startDate,endDate,length(dataset)-1);
% para_names = {'y_bar(1)','pi_bar(2)','r_bar(3)','kappa(4)','tau(5)',...
%     'phi_pi(6)','phi_y(7)','phi_dy(8)','rho_y(9)','rho_pi(10)','rho_r(11)',...
%     'eta_y(12)','eta_pi(13)','eta_r(14)','iota_y(15)','iota_p(16)',...
%     'r_bar_zlb(17)','eta_r_zlb(18)','1-p_11(19)','1-p_22(20)','gain(21)'};
param(:,1)=parameters(1:16);
param(:,2)=parameters(1:16);
param(:,3)=parameters(1:16);

%r_bar for ZLB and forward guidance regimes
param(3,2)=parameters(17);
param(3,3)=parameters(17);

%eta_r for ZLB and forward guidance regimes
param(14,2)=parameters(18);
param(14,3)=parameters(18);

%monetary policy parameters for FG and ZLB regimes--inactive taylor rule
param(6,2)=0;param(7,2)=0;param(8,2) = 0;param(11,2)=0;
param(6,3)=0;param(7,3)=0;param(8,3) = 0;param(11,3)=0;

gain=parameters(21);

Sigma1=diag([param(end-4,1)^2;param(end-3,1)^2;param(end-2,1)^2]);
Sigma2=diag([param(end-4,2)^2;param(end-3,2)^2;param(end-2,2)^2]);
Sigma3=diag([param(end-4,3)^2;param(end-3,3)^2;param(end-2,3)^2]);

[A_ree B_ree C_ree D_ree RHO_ree] = NKPC_sysmat_REE(param(:,1));
[gam1_REE gam3_REE,gam0_eps,gamma1,gamma3,gam0_rec,gam1_rec,rho_rec]= MSV_solution(A_ree,B_ree, C_ree, D_ree, RHO_ree,Sigma1)
%[bb     ,dd      ,gam0_eps,gamma1,gamma3  ,gam0_rec,gam1_rec]=REE_solve_uhlig(AA,BB,CC,DD,RHO,SIGMA)
%initial belief model for VAR system
%retrieve initial belief model
 fl_indices= [1 2 3]; 
bl_indices=[1 2 3];
rr_init=eye(4);
rr_init(2:end,2:end) = gam0_rec(bl_indices,bl_indices);
beta_init = rho_rec(fl_indices,bl_indices);
%-------------------------------------------------------------
%REE solution consistent with the active Taylor rule model
% X_t = gam1_REE * X_{t-1} + gam3_REE * eps_t ;
% eps_t = RHO* eps_{t-1} + eta_t;

%gam1_REE and gam3_REE used for agents belief model