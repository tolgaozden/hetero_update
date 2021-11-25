clear;clc;%close all;
% load('estimation_results_march15.mat');
% load estimation_results_var1.mat;
load estimation_results_march15
% load param_init;
% parameters=param_init;

para_names = {'y_bar(1)','pi_bar(2)','r_bar(3)','kappa(4)','tau(5)',...
    'phi_pi(6)','phi_y(7)','phi_dy(8)','rho_y(9)','rho_pi(10)','rho_r(11)',...
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
parameters(4)=0.01;
parameters(10)=0.9;
parameters(12)=0.1;
parameters(15)=0.1;
parameters(16)=0.3;
% parameters(2)=0.3;
r_bar1 = parameters(3);
r_bar2 = parameters(17);
pi_bar = parameters(2);
y_bar = parameters(1);

% parameters(7)=0.2;
parameters=vec(parameters);
table(para_names',parameters)
%clear;clc;close all;
%parameters=[0.06 0.97 1.34 0.036 3.13 1.32 0.35 0.38 0.05 0.98 0.74 0.26 0.33 0.04 0.02 0.02 0.10 0.005];    
%clear;clc;load('us_dataset.mat');dataset=[gap_hp,pinfobs,robs];
%dataset=dataset(44:end,:);

% load('us_dataset.mat');
% first_obs=100;burn_in=4;
% dataset=[gap_quadratic,pinfobs,robs];
% dataset=dataset(first_obs:end,:);


zlb_threshold=107;
zlb_threshold2=139;
load('us_dataset_survey.mat');
first_obs=4;
burn_in=4;
%first_obs=164;burn_in=4;
%dataset=[gap_detrend2,pinfobs,robs,gap_exp_fore,pinf_mean_fore];
dataset=[gap_detrend2,pinfobs,robs];
dataset=dataset(first_obs:end,:);




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

phi_pi_taylor = parameters(6);
phi_y_taylor = parameters(7);
phi_dy_taylor = parameters(8);
rho_r_taylor = parameters(11);
   
Q = [0.9 0.05 0.05; 
    0.05 0.9 0.05;
    0.05 0.99  0.05];

q_11 = Q(1,1);
q_12 = Q(1,2);
q_13 = Q(1,3);
q_21 = Q(2,1);
q_22 = Q(2,2);
q_23 = Q(2,3);
q_31 = Q(3,1);
q_32 = Q(3,2);
q_33 = Q(3,3);

% ergodic_states=[(1-q_22)/(2-q_11-q_22);(1-q_11)/(2-q_11-q_22)];
% q_11=Q(1,1);q_12=Q(1,2);q_21=Q(2,1);q_22=Q(2,2);
numVar=9;
numExo=2;
numObs=3;
numRegimes=2;
T=size(dataset,1);l=3;


Sigma1=diag([param(end-4,1)^2;param(end-3,1)^2;param(end-2,1)^2]);
Sigma2=diag([param(end-4,2)^2;param(end-3,2)^2;param(end-2,2)^2]);
Sigma3=diag([param(end-4,3)^2;param(end-3,3)^2;param(end-2,3)^2]);



%   alpha1=0*ones(numVar,1);beta1=0*eye(numVar);rr1=zeros(4,4);
%  load('VAR1_initial_beliefs.mat');
% alpha1(1:3)=alpha_init(1:3);
%  beta1(1:3,1:3)=beta_init(1:3,1:3);
% rr1=rr_init;
% 
%   alpha2=0*ones(numVar,1);beta2=0*eye(numVar);rr2=zeros(4,4);
%  load('VAR1_initial_beliefs.mat');
% alpha2(1:3)=alpha_init(1:3);
%  beta2(1:3,1:3)=beta_init(1:3,1:3);
% rr2=rr_init;


alpha1=zeros(numVar,1);
beta1=0*eye(numVar);
alpha2=zeros(numVar,1);
beta2=0*eye(numVar);
 [beta_init,rr_init,  bb_REE,  dd_REE,gam1_rec_REE,gam3_rec_REE]=REE_initialize_beliefs(param(:,1),Sigma1);
 beta_init