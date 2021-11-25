   function[likl]=KF_MS_VAR1(parameters)
% parameters(15)=0;
% parameters(16)=0; 
THETA1=1;
THETA2=1;
PHI1=parameters(18)*100;
PHI2=parameters(19)*100;
memory=parameters(21);
intensity=parameters(22);

r_bar1 = parameters(2);
r_bar2 = parameters(16);
pi_bar = parameters(1);

y_bar = 0;

parameters=vec(parameters);
% table(para_names',parameters)







load('us_dataset_survey.mat');
first_obs=4;
burn_in=4;
%first_obs=164;burn_in=4;
%dataset=[gap_detrend2,pinfobs,robs,gap_exp_fore,pinf_mean_fore];
dataset=[gap_detrend2,pinfobs,robs];
dataset=dataset(first_obs:end,:);

% load('final_dataset.mat');
% first_obs=90;
% burn_in=4;
% %first_obs=164;burn_in=4;
% %dataset=[gap_detrend2,pinfobs,robs,gap_exp_fore,pinf_mean_fore];
% dataset=[gap_detrend2_us,pinfobs_us,robs_us];
% dataset=dataset(first_obs:end,:);

zlb_threshold=length(dataset)-44;
zlb_threshold2=length(dataset)-16;



startDate=datenum('01-06-1982');
endDate = datenum('01-12-2019');
Date=linspace(startDate,endDate,length(dataset)-1);

%taylor rule regimes
param(:,1)=parameters(1:15);
param(:,2)=parameters(1:15);

%zlb regimes
param(:,3)=parameters(1:15);
param(:,4)=parameters(1:15);

%r_bar for ZLB and forward guidance regimes
param(2,3)=parameters(16);
param(2,4)=parameters(16);

%eta_r for ZLB and forward guidance regimes
param(13,3)=parameters(17);
param(13,4)=parameters(17);

%monetary policy parameters for FG and ZLB regimes--inactive taylor rule
param(5,3)=0;param(6,3)=0;param(7,3) = 0;param(10,3)=0;
param(5,4)=0;param(6,4)=0;param(7,4) = 0;param(10,4)=0;

gain_y=parameters(20);
% gain_pinf=parameters(21);
% gain_r = parameters(25);
gain_r = 0.001;

% gain_vec = [gain_y gain_pinf gain_r]';

phi_pi_taylor = parameters(5);
phi_y_taylor = parameters(6);
phi_dy_taylor = parameters(7);
rho_r_taylor = parameters(10);
   
Q = [ 0.987/2 0.987/2 (1-0.987)/2 (1-0.987)/2 ; 
      0.987/2 0.987/2 (1-0.987)/2 (1-0.987)/2 ; 
      (1-0.964)/2 (1-0.964)/2 0.964/2 0.964/2 ; 
      (1-0.964)/2 (1-0.964)/2 0.964/2 0.964/2] ; 



q_11 = Q(1,1);
q_12 = Q(1,2);
q_13 = Q(1,3);
q_14 = Q(1,4);
q_21 = Q(2,1);
q_22 = Q(2,2);
q_23 = Q(2,3);
q_24 = Q(2,4);
q_31 = Q(3,1);
q_32 = Q(3,2);
q_33 = Q(3,3);
q_34 = Q(3,4);
q_41 = Q(4,1); 
q_42 = Q(4,2);
q_43 = Q(4,3);
q_44 = Q(4,4);


numVar=9;
numExo=2;
numObs=3;
numRegimes=2;
T=size(dataset,1);l=3;


Sigma1=diag([param(end-4,1)^2;param(end-3,1)^2;param(end-2,1)^2]);
Sigma2=diag([param(end-4,2)^2;param(end-3,2)^2;param(end-2,2)^2]);
Sigma3=diag([param(end-4,3)^2;param(end-3,3)^2;param(end-2,3)^2]);
Sigma4=diag([param(end-4,3)^2;param(end-3,4)^2;param(end-2,4)^2]);

  alpha1=0*ones(numVar,1);
  beta1=0*eye(numVar);
%   rr1=zeros(4,4,2);
 load('VAR1_initial_beliefs.mat');
 beta1= beta_init;
 rr1 = rr_init;
% beta1(1,1)=beta_init(1);
% beta1(2,2)=beta_init(2);
% rr1(:,:,1)=rr_init(:,:,1);
% rr1(:,:,2)=rr_init(:,:,2);
% alpha1_old = alpha1;
% beta1_old = beta1;

 [beta_init,rr_init,bb_REE,dd_REE,gam1_rec_REE,gam3_rec_REE, gam0_moments,gam1_moments,autocorr_REE,rho_REE]=...
     REE_initialize_beliefs(param(:,1),Sigma1(1:3,1:3));

% beta1=beta_init;
% rr1= rr_init;

% rr1(:,:,1) = eye(4);
% rr1(:,:,2) = eye(4);
% beta1(1,1)=beta_init(1,1);
% beta1(2,2)=beta_init(2,2);
% rr1(:,:,1)=rr_init(:,:,1);
% rr1(:,:,2)=rr_init(:,:,2);
alpha1_old = alpha1;
beta1_old = beta1;


%Taylor rule, VAR-learning
[gamma1_1, gamma2_1, gamma3_1, E1, F1]=NKPC_sysmat_regime1(param(:,1),beta1,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,1,r_bar1,r_bar2);

%Taylor rule, MSV solution
[gamma1_2, gamma2_2, gamma3_2, E2, F2]=NKPC_sysmat_regime2(param(:,2),bb_REE,dd_REE,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,1,r_bar1,r_bar2);

%ZLB regime, VAR-learning
[gamma1_3, gamma2_3, gamma3_3, E3, F3]=NKPC_sysmat_regime3(param(:,3),beta1,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,1,r_bar1,r_bar2);

%ZLB regime, MSV solution 
[gamma1_4, gamma2_4, gamma3_4, E4, F4]=NKPC_sysmat_regime4(param(:,4),bb_REE,dd_REE,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,1,r_bar1,r_bar2);






H1=0.0*diag(var(dataset(1:zlb_threshold,:)));
H2=0.0*diag(var(dataset(1:zlb_threshold,:)));
H3=0.0*diag(var(dataset(zlb_threshold:zlb_threshold2,:)));
H4=0.0*diag(var(dataset(zlb_threshold:zlb_threshold2,:)));


S_fore11=zeros(numVar,1);
S_fore12=zeros(numVar,1);
S_fore13=zeros(numVar,1);
S_fore14=zeros(numVar,1);
S_fore21=zeros(numVar,1);
S_fore22=zeros(numVar,1);
S_fore23=zeros(numVar,1);
S_fore24=zeros(numVar,1);
S_fore31=zeros(numVar,1);
S_fore32=zeros(numVar,1);
S_fore33=zeros(numVar,1);
S_fore34=zeros(numVar,1);
S_fore41=zeros(numVar,1);
S_fore42=zeros(numVar,1);
S_fore43=zeros(numVar,1);
S_fore44=zeros(numVar,1);

P_fore11=zeros(numVar,numVar);
P_fore12=zeros(numVar,numVar);
P_fore13=zeros(numVar,numVar);
P_fore14=zeros(numVar,numVar);

P_fore21=zeros(numVar,numVar);
P_fore22=zeros(numVar,numVar);
P_fore23=zeros(numVar,numVar);
P_fore24=zeros(numVar,numVar);

P_fore31=zeros(numVar,numVar);
P_fore32=zeros(numVar,numVar);
P_fore33=zeros(numVar,numVar);
P_fore34=zeros(numVar,numVar);

P_fore41=zeros(numVar,numVar);
P_fore42=zeros(numVar,numVar);
P_fore43=zeros(numVar,numVar);
P_fore44=zeros(numVar,numVar);

v11=zeros(numObs,1);
v12=zeros(numObs,1);
v13=zeros(numObs,1);
v14=zeros(numObs,1);

v21=zeros(numObs,1);
v22=zeros(numObs,1);
v23=zeros(numObs,1);
v24=zeros(numObs,1);

v31=zeros(numObs,1);
v32=zeros(numObs,1);
v33=zeros(numObs,1);
v34=zeros(numObs,1);

Fe11=zeros(numObs,numObs);
Fe12=zeros(numObs,numObs);
Fe13=zeros(numObs,numObs);
Fe14=zeros(numObs,numObs);

Fe21=zeros(numObs,numObs);
Fe22=zeros(numObs,numObs);
Fe23=zeros(numObs,numObs);
Fe24=zeros(numObs,numObs);

Fe31=zeros(numObs,numObs);
Fe32=zeros(numObs,numObs);
Fe33=zeros(numObs,numObs);
Fe34=zeros(numObs,numObs);

Fe41=zeros(numObs,numObs);
Fe42=zeros(numObs,numObs);
Fe43=zeros(numObs,numObs);
Fe44=zeros(numObs,numObs);

S_upd11=zeros(numVar,1);
S_upd12=zeros(numVar,1);
S_upd13=zeros(numVar,1);
S_upd14=zeros(numVar,1);

S_upd21=zeros(numVar,1);
S_upd22=zeros(numVar,1);
S_upd23=zeros(numVar,1);
S_upd24=zeros(numVar,1);

S_upd31=zeros(numVar,1);
S_upd32=zeros(numVar,1);
S_upd33=zeros(numVar,1);
S_upd34=zeros(numVar,1);

S_upd41=zeros(numVar,1);
S_upd42=zeros(numVar,1);
S_upd43=zeros(numVar,1);
S_upd44=zeros(numVar,1);


P_upd11=zeros(numVar,numVar);
P_upd12=zeros(numVar,numVar);
P_upd13=zeros(numVar,numVar);
P_upd14=zeros(numVar,numVar);
P_upd21=zeros(numVar,numVar);
P_upd22=zeros(numVar,numVar);
P_upd23=zeros(numVar,numVar);
P_upd24=zeros(numVar,numVar);
P_upd31=zeros(numVar,numVar);
P_upd32=zeros(numVar,numVar);
P_upd33=zeros(numVar,numVar);
P_upd34=zeros(numVar,numVar);
P_upd41=zeros(numVar,numVar);
P_upd42=zeros(numVar,numVar);
P_upd43=zeros(numVar,numVar);
P_upd44=zeros(numVar,numVar);


ml11=0;
ml12=0;
ml13=0;
ml14=0;
ml21=0;
ml22=0;
ml23=0;
ml24=0;
ml31=0;
ml32=0;
ml33=0;
ml34=0;
ml41=0;
ml42=0;
ml43=0;
ml44=0;
likl=zeros(T,1);

pp_fore11=1;pp_fore12=0;pp_fore13=0;pp_fore14=0;
pp_fore21=0;pp_fore22=0;pp_fore23=0;pp_fore24=0;
pp_fore31=0;pp_fore32=0;pp_fore33=0;pp_fore34=0;
pp_fore41=0;pp_fore42=0;pp_fore43=0;pp_fore44=0;

pp_upd11=1;pp_upd12=0;pp_upd13=0;pp_upd14=0;
pp_upd21=0;pp_upd22=0;pp_upd23=0;pp_upd24=0;
pp_upd31=0;pp_upd32=0;pp_upd33=0;pp_upd34=0;
pp_upd41=0;pp_upd42=0;pp_upd43=0;pp_upd44=0;

pp_collapse1=0.5;pp_collapse2=0.5;pp_collapse3=0;pp_collapse4=0;
pp_filtered=0*ones(T,4);

S_collapse1=zeros(numVar,1);S_collapse2=zeros(numVar,1);S_collapse3=zeros(numVar,1);S_collapse4=zeros(numVar,1);

P_collapse1=10*eye(numVar);P_collapse2=10*eye(numVar);P_collapse3=10*eye(numVar);P_collapse4=10*eye(numVar);
S_filtered=zeros(T,numVar);


%----------------------------------------------------------------------------
intercept1=zeros(numVar,1);
intercept2=zeros(numVar,1);
intercept3=zeros(numVar,1);
intercept4=zeros(numVar,1);


intercept3(3)=-(r_bar1-r_bar2);
intercept4(3)=-(r_bar1-r_bar2);




S_collapse1(1) = dataset(1,1);
S_collapse1(2) = dataset(1,2)-parameters(2);
S_collapse1([3 8 9]) = dataset(1,3) - parameters(3);

S_collapse2(1) = dataset(1,1);
S_collapse2(2) = dataset(1,2)-parameters(2);
S_collapse2([3 8 9]) = dataset(1,3) - parameters(3);

S_collapse3(1) = dataset(1,1);
S_collapse3(2) = dataset(1,2)-parameters(2);
S_collapse3([3 8 9]) = dataset(1,3) - parameters(3);

S_collapse4(1) = dataset(1,1);
S_collapse4(2) = dataset(1,2)-parameters(2);
S_collapse4([3 8 9]) = dataset(1,3) - parameters(3);

shadow_rate =zeros(T,1);
shadow_rate(1) = dataset(1,3);

fore1= zeros(numVar,1);
fore2= zeros(numVar,2);
fitness1= zeros(T,1);
fitness2= zeros(T,1);
n1=0.5*ones(T,1);
n2=0.5*ones(T,1);

projectionFlag = zeros(T,1);
for tt=2:T
    
    %when using sac_learning algorithms
%gamma1_1=A1_inv*(B1+C1*beta1^2);gamma2_1=A1_inv*C1*(eye(numVar)-beta1^2)*alpha1;gamma3_1=A1_inv*D1;
%gamma1_2=A2_inv*(B2+C2*beta1^2);gamma2_2=A2_inv*C2*(eye(numVar)-beta1^2)*alpha1;gamma3_2=A1_inv*D2;

   %when using msv_learning algorithms. Only intercepts are different

    x_tt=dataset(tt,:)';

%kalman block
S_fore11=intercept1+gamma1_1*S_collapse1+gamma2_1;%
S_fore12=intercept2+gamma1_2*S_collapse1+gamma2_2;%
S_fore13=intercept3+gamma1_3*S_collapse1+gamma2_3;%
S_fore14=intercept4+gamma1_4*S_collapse1+gamma2_4;%

S_fore21=intercept1+gamma1_1*S_collapse2+gamma2_1;%
S_fore22=intercept2+gamma1_2*S_collapse2+gamma2_2;%
S_fore23=intercept3+gamma1_3*S_collapse2+gamma2_3;%
S_fore24=intercept4+gamma1_4*S_collapse2+gamma2_4;%

S_fore31=intercept1+gamma1_1*S_collapse3+gamma2_1;%
S_fore32=intercept2+gamma1_2*S_collapse3+gamma2_2;%
S_fore33=intercept3+gamma1_3*S_collapse3+gamma2_3;%
S_fore34=intercept4+gamma1_4*S_collapse3+gamma2_4;%

S_fore41=intercept1+gamma1_1*S_collapse4+gamma2_1;%
S_fore42=intercept2+gamma1_2*S_collapse4+gamma2_2;%
S_fore43=intercept3+gamma1_3*S_collapse4+gamma2_3;%
S_fore44=intercept4+gamma1_4*S_collapse4+gamma2_4;%
%
P_fore11=gamma1_1*P_collapse1*gamma1_1'+gamma3_1*Sigma1*gamma3_1';
P_fore12=gamma1_2*P_collapse1*gamma1_2'+gamma3_2*Sigma2*gamma3_2';  
P_fore13=gamma1_3*P_collapse1*gamma1_3'+gamma3_3*Sigma3*gamma3_3';
P_fore14=gamma1_4*P_collapse1*gamma1_4'+gamma3_4*Sigma4*gamma3_4';

P_fore21=gamma1_1*P_collapse2*gamma1_1'+gamma3_1*Sigma1*gamma3_1';
P_fore22=gamma1_2*P_collapse2*gamma1_2'+gamma3_2*Sigma2*gamma3_2';
P_fore23=gamma1_3*P_collapse2*gamma1_3'+gamma3_3*Sigma3*gamma3_3';
P_fore24=gamma1_4*P_collapse2*gamma1_4'+gamma3_4*Sigma4*gamma3_4';

P_fore31=gamma1_1*P_collapse3*gamma1_1'+gamma3_1*Sigma1*gamma3_1';
P_fore32=gamma1_2*P_collapse3*gamma1_2'+gamma3_2*Sigma2*gamma3_2';
P_fore33=gamma1_3*P_collapse3*gamma1_3'+gamma3_3*Sigma3*gamma3_3';
P_fore34=gamma1_4*P_collapse3*gamma1_4'+gamma3_4*Sigma4*gamma3_4';

P_fore41=gamma1_1*P_collapse4*gamma1_1'+gamma3_1*Sigma1*gamma3_1';
P_fore42=gamma1_2*P_collapse4*gamma1_2'+gamma3_2*Sigma2*gamma3_2';
P_fore43=gamma1_3*P_collapse4*gamma1_3'+gamma3_3*Sigma3*gamma3_3';
P_fore44=gamma1_4*P_collapse4*gamma1_4'+gamma3_4*Sigma4*gamma3_4';
%    
v11=x_tt-E1-F1*S_fore11;
v12=x_tt-E1-F2*S_fore12;
v13=x_tt-E1-F3*S_fore13;
v14=x_tt-E1-F4*S_fore14;

v21=x_tt-E1-F1*S_fore21;
v22=x_tt-E1-F2*S_fore22;
v23=x_tt-E1-F3*S_fore23;
v24=x_tt-E1-F4*S_fore24;

v31=x_tt-E1-F1*S_fore31;
v32=x_tt-E1-F2*S_fore32;
v33=x_tt-E1-F3*S_fore33;
v34=x_tt-E1-F4*S_fore34;

v41=x_tt-E1-F1*S_fore41;
v42=x_tt-E1-F2*S_fore42;
v43=x_tt-E1-F3*S_fore43;
v44=x_tt-E1-F4*S_fore44;
%
Fe11=F1*P_fore11*F1'+H1;
Fe12=F2*P_fore12*F2'+H2;
Fe13=F3*P_fore13*F3'+H3;
Fe14=F4*P_fore14*F4'+H4;

Fe21=F1*P_fore21*F1'+H1;
Fe22=F2*P_fore22*F2'+H2;
Fe23=F3*P_fore23*F3'+H3;
Fe24=F4*P_fore24*F4'+H4;

Fe31=F1*P_fore31*F1'+H1;
Fe32=F2*P_fore32*F2'+H2;
Fe33=F3*P_fore33*F3'+H3;
Fe34=F4*P_fore34*F4'+H4;

Fe41=F1*P_fore41*F1'+H1;
Fe42=F2*P_fore42*F2'+H2;
Fe43=F3*P_fore43*F3'+H3;
Fe44=F4*P_fore44*F4'+H4;
%
S_upd11=S_fore11+P_fore11*F1'*(Fe11^(-1))*v11;
S_upd12=S_fore12+P_fore12*F2'*(Fe12^(-1))*v12;
S_upd13=S_fore13+P_fore13*F3'*(Fe13^(-1))*v13;
S_upd14=S_fore14+P_fore14*F4'*(Fe14^(-1))*v14;

S_upd21=S_fore21+P_fore21*F1'*(Fe21^(-1))*v21;
S_upd22=S_fore22+P_fore22*F2'*(Fe22^(-1))*v22;
S_upd23=S_fore23+P_fore23*F3'*(Fe23^(-1))*v23;
S_upd24=S_fore24+P_fore24*F4'*(Fe24^(-1))*v24;

S_upd31=S_fore31+P_fore31*F1'*(Fe31^(-1))*v31;
S_upd32=S_fore32+P_fore32*F2'*(Fe32^(-1))*v32;
S_upd33=S_fore33+P_fore33*F3'*(Fe33^(-1))*v33;
S_upd34=S_fore34+P_fore34*F4'*(Fe34^(-1))*v34;

S_upd41=S_fore41+P_fore41*F1'*(Fe41^(-1))*v41;
S_upd42=S_fore42+P_fore42*F2'*(Fe42^(-1))*v42;
S_upd43=S_fore43+P_fore43*F3'*(Fe43^(-1))*v43;
S_upd44=S_fore44+P_fore44*F4'*(Fe44^(-1))*v44;

%  S_upd_all(:,:,tt) = [S_upd11 S_upd12 S_upd13 S_upd14 ...
%      S_upd21 S_upd22 S_upd23 S_upd24 ...
%      S_upd31 S_upd32 S_upd33 S_upd34 ...
%      S_upd41 S_upd42 S_upd43 S_upd44];


shadow_rate(tt) = S_upd11(9);
% 
 q_taylor(tt)=THETA1/(THETA1+exp(-PHI1*(shadow_rate(tt)+(r_bar1-r_bar2))));
 q_zlb(tt)=THETA2/(THETA2+exp(+PHI2*(shadow_rate(tt))+(r_bar1-r_bar2)));
 
 
 q_11= q_taylor(tt)*n1(tt-1);
 q_12 =q_taylor(tt)*n2(tt-1);
 q_13= (1-q_taylor(tt))*n1(tt-1);
 q_14= (1-q_taylor(tt))*n2(tt-1);
% 
 q_21= q_taylor(tt)*n1(tt-1);
 q_22 =q_taylor(tt)*n2(tt-1);
 q_23= (1-q_taylor(tt))*n1(tt-1);
 q_24= (1-q_taylor(tt))*n2(tt-1);
 
 q_31 = (1-q_zlb(tt))*n1(tt-1);
 q_32 = (1-q_zlb(tt))*n2(tt-1);
 q_33 = q_zlb(tt) * n1(tt-1);
 q_34 = q_zlb(tt) * n2(tt-1);
  
 q_41 = (1-q_zlb(tt))*n1(tt-1);
 q_42 = (1-q_zlb(tt))*n2(tt-1);
 q_43 = q_zlb(tt) * n1(tt-1);
 q_44 = q_zlb(tt) * n2(tt-1);


Q = [q_11,q_12,q_13 q_14;q_21,q_22,q_23 q_24; q_31,q_32,q_33 q_34; q_41 q_42 q_43 q_44];
% Q_tv(:,:,tt) = Q;

%
P_upd11=(eye(numVar)-P_fore11*F1'*Fe11^(-1)*F1)*P_fore11;    
P_upd12=(eye(numVar)-P_fore12*F2'*Fe12^(-1)*F2)*P_fore12;  
P_upd13=(eye(numVar)-P_fore13*F3'*Fe13^(-1)*F3)*P_fore13;  
P_upd14=(eye(numVar)-P_fore14*F4'*Fe14^(-1)*F4)*P_fore14; 

P_upd21=(eye(numVar)-P_fore21*F1'*Fe21^(-1)*F1)*P_fore21;  
P_upd22=(eye(numVar)-P_fore22*F2'*Fe22^(-1)*F2)*P_fore22;  
P_upd23=(eye(numVar)-P_fore23*F3'*Fe23^(-1)*F3)*P_fore23;  
P_upd24=(eye(numVar)-P_fore24*F4'*Fe24^(-1)*F4)*P_fore24;  

P_upd31=(eye(numVar)-P_fore31*F1'*Fe31^(-1)*F1)*P_fore31;  
P_upd32=(eye(numVar)-P_fore32*F2'*Fe32^(-1)*F2)*P_fore32;  
P_upd33=(eye(numVar)-P_fore33*F3'*Fe33^(-1)*F3)*P_fore33; 
P_upd34=(eye(numVar)-P_fore34*F4'*Fe34^(-1)*F4)*P_fore34;

P_upd41=(eye(numVar)-P_fore41*F1'*Fe41^(-1)*F1)*P_fore41;  
P_upd42=(eye(numVar)-P_fore42*F2'*Fe42^(-1)*F2)*P_fore42;  
P_upd43=(eye(numVar)-P_fore43*F3'*Fe43^(-1)*F3)*P_fore43; 
P_upd44=(eye(numVar)-P_fore44*F4'*Fe44^(-1)*F4)*P_fore44;
%
pp_fore11=q_11*pp_collapse1;
pp_fore12=q_12*pp_collapse1;
pp_fore13=q_13*pp_collapse1;
pp_fore14=q_14*pp_collapse1;

pp_fore21=q_21*pp_collapse2;
pp_fore22=q_22*pp_collapse2;
pp_fore23=q_23*pp_collapse2;
pp_fore24=q_24*pp_collapse2;

pp_fore31=q_31*pp_collapse3;
pp_fore32=q_32*pp_collapse3;
pp_fore33=q_33*pp_collapse3;
pp_fore34=q_34*pp_collapse3;

pp_fore41=q_41*pp_collapse4;
pp_fore42=q_42*pp_collapse4;
pp_fore43=q_43*pp_collapse4;
pp_fore44=q_44*pp_collapse4;
%
ml11=(2*pi)^(-l/2)*det(Fe11)^(-0.5)*exp(-0.5*v11'*Fe11^(-1)*v11);
ml12=(2*pi)^(-l/2)*det(Fe12)^(-0.5)*exp(-0.5*v12'*Fe12^(-1)*v12);
ml13=(2*pi)^(-l/2)*det(Fe13)^(-0.5)*exp(-0.5*v13'*Fe13^(-1)*v13);
ml14=(2*pi)^(-l/2)*det(Fe14)^(-0.5)*exp(-0.5*v14'*Fe14^(-1)*v14);

ml21=(2*pi)^(-l/2)*det(Fe21)^(-0.5)*exp(-0.5*v21'*Fe21^(-1)*v21);
ml22=(2*pi)^(-l/2)*det(Fe22)^(-0.5)*exp(-0.5*v22'*Fe22^(-1)*v22);
ml23=(2*pi)^(-l/2)*det(Fe23)^(-0.5)*exp(-0.5*v23'*Fe23^(-1)*v23);
ml24=(2*pi)^(-l/2)*det(Fe24)^(-0.5)*exp(-0.5*v24'*Fe24^(-1)*v24);


ml31=(2*pi)^(-l/2)*det(Fe31)^(-0.5)*exp(-0.5*v31'*Fe31^(-1)*v31);
ml32=(2*pi)^(-l/2)*det(Fe32)^(-0.5)*exp(-0.5*v32'*Fe32^(-1)*v32);
ml33=(2*pi)^(-l/2)*det(Fe33)^(-0.5)*exp(-0.5*v33'*Fe33^(-1)*v33);
ml34=(2*pi)^(-l/2)*det(Fe34)^(-0.5)*exp(-0.5*v34'*Fe34^(-1)*v34);

ml41=(2*pi)^(-l/2)*det(Fe41)^(-0.5)*exp(-0.5*v41'*Fe41^(-1)*v41);
ml42=(2*pi)^(-l/2)*det(Fe42)^(-0.5)*exp(-0.5*v42'*Fe42^(-1)*v42);
ml43=(2*pi)^(-l/2)*det(Fe43)^(-0.5)*exp(-0.5*v43'*Fe43^(-1)*v43);
ml44=(2*pi)^(-l/2)*det(Fe44)^(-0.5)*exp(-0.5*v44'*Fe44^(-1)*v44);
% 
likl(tt)=ml11*pp_fore11+    ml12*pp_fore12+     ml13*pp_fore13+ ml14*pp_fore14 +...
         ml21*pp_fore21+    ml22*pp_fore22+     ml23*pp_fore23+ ml24*pp_fore24 +...
         ml31*pp_fore31+    ml32*pp_fore32+     ml33*pp_fore33+ ml34*pp_fore34 +...
         ml41*pp_fore41+    ml42*pp_fore42+     ml43*pp_fore43+ ml44*pp_fore44;

% ml(:,tt) = [ml11 ml12 ml13 ml14 ml21 ml22 ml23 ml24 ml31 ml32 ml33 ml34 ml41 ml42 ml43 ml44];
% vv_all(:,:,tt) =[v11 v12 v13 v14 v21 v22 v23 v24 v31 v32 v33 v34 v41 v42 v43 v44];
%
pp_upd11=(ml11*pp_fore11)/likl(tt);
pp_upd12=(ml12*pp_fore12)/likl(tt);
pp_upd13=(ml13*pp_fore13)/likl(tt);
pp_upd14=(ml14*pp_fore14)/likl(tt);

pp_upd21=(ml21*pp_fore21)/likl(tt);
pp_upd22=(ml22*pp_fore22)/likl(tt);
pp_upd23=(ml23*pp_fore23)/likl(tt);
pp_upd24=(ml24*pp_fore24)/likl(tt);

pp_upd31=(ml31*pp_fore31)/likl(tt);
pp_upd32=(ml32*pp_fore32)/likl(tt);
pp_upd33=(ml33*pp_fore33)/likl(tt);
pp_upd34=(ml34*pp_fore34)/likl(tt);

pp_upd41=(ml41*pp_fore41)/likl(tt);
pp_upd42=(ml42*pp_fore42)/likl(tt);
pp_upd43=(ml43*pp_fore43)/likl(tt);
pp_upd44=(ml44*pp_fore44)/likl(tt);
%
pp_collapse1=pp_upd11+pp_upd21+pp_upd31+pp_upd41;
pp_collapse2=pp_upd12+pp_upd22+pp_upd32+pp_upd42;
pp_collapse3=pp_upd13+pp_upd23+pp_upd33+pp_upd43;
pp_collapse4=pp_upd14+pp_upd24+pp_upd34+pp_upd44;

if pp_collapse1>10e-5;
    S_collapse1=(pp_upd11*S_upd11+pp_upd21*S_upd21+S_upd31*pp_upd31+S_upd41*pp_upd41)/pp_collapse1;
P_collapse1=(pp_upd11*(P_upd11+(S_collapse1-S_upd11)*(S_collapse1-S_upd11)')+...
    pp_upd21*(P_upd21+(S_collapse1-S_upd21)*(S_collapse1-S_upd21)')+...
  pp_upd31*(P_upd31+(S_collapse1-S_upd31)*(S_collapse1-S_upd31)')+...
  pp_upd41*(P_upd41+(S_collapse1-S_upd41)*(S_collapse1-S_upd41)'))/pp_collapse1;
else
    S_collapse1=(S_upd11+S_upd21+S_upd31+S_upd41)/4;
    P_collapse1=(P_upd11+P_upd21+P_upd31+P_upd41)/4;
end

if pp_collapse2>10e-5
  S_collapse2=(pp_upd12*S_upd12+pp_upd22*S_upd22+pp_upd32*S_upd32+pp_upd42*S_upd42)/pp_collapse2;
P_collapse2=(pp_upd12*(P_upd12+(S_collapse2-S_upd12)*(S_collapse2-S_upd12)')+...
    pp_upd22*(P_upd22+(S_collapse2-S_upd22)*(S_collapse2-S_upd22)')+...
   pp_upd32*(P_upd32+(S_collapse2-S_upd32)*(S_collapse2-S_upd32)')+...
   pp_upd42*(P_upd42+(S_collapse2-S_upd42)*(S_collapse2-S_upd42)'))/pp_collapse2;
else
    S_collapse2=(S_upd12+S_upd22+S_upd32+S_upd42)/4;
    P_collapse2=(P_upd12+P_upd22+P_upd32+P_upd42)/4;
end

if pp_collapse3>10e-5
  S_collapse3=(pp_upd13*S_upd13+pp_upd23*S_upd23+pp_upd33*S_upd33+pp_upd43*S_upd43)/pp_collapse3;
P_collapse3=(pp_upd13*(P_upd13+(S_collapse3-S_upd13)*(S_collapse3-S_upd13)')+...
    pp_upd23*(P_upd23+(S_collapse3-S_upd23)*(S_collapse3-S_upd23)')+...
   pp_upd33*(P_upd33+(S_collapse3-S_upd33)*(S_collapse3-S_upd33)')+...
   pp_upd43*(P_upd43+(S_collapse3-S_upd43)*(S_collapse3-S_upd43)'))/pp_collapse3;
else
    S_collapse3=(S_upd13+S_upd23+S_upd33+S_upd43)/4;
    P_collapse3=(P_upd13+P_upd23+P_upd33+P_upd43)/4;
end

if pp_collapse4>10e-5
  S_collapse4=(pp_upd14*S_upd14+pp_upd24*S_upd24+pp_upd34*S_upd34+pp_upd44*S_upd44)/pp_collapse4;
P_collapse4=(pp_upd14*(P_upd14+(S_collapse4-S_upd14)*(S_collapse4-S_upd14)')+...
    pp_upd24*(P_upd24+(S_collapse4-S_upd24)*(S_collapse4-S_upd24)')+...
   pp_upd34*(P_upd34+(S_collapse4-S_upd34)*(S_collapse4-S_upd34)')+...
   pp_upd44*(P_upd44+(S_collapse4-S_upd44)*(S_collapse4-S_upd44)'))/pp_collapse4;
else
    S_collapse4=(S_upd14+S_upd24+S_upd34+S_upd44)/4;
    P_collapse4=(P_upd14+P_upd24+P_upd34+P_upd44)/4;
end


%

S_filtered(tt,:)=pp_collapse1*S_collapse1+pp_collapse2*S_collapse2+pp_collapse3*S_collapse3+pp_collapse4*S_collapse4;
% S_collapse1_all(:,tt) = S_collapse1;
% S_collapse2_all(:,tt) = S_collapse2;
% S_collapse3_all(:,tt) = S_collapse3;
% S_collapse4_all(:,tt) = S_collapse4;

pp_filtered(tt,:)=[pp_collapse1,pp_collapse2,pp_collapse3,pp_collapse4];




   
fore1= alpha1_old(1:3)+beta1_old(1:3,1:3)*S_filtered(tt-1,1:3)';
fore2= bb_REE * S_filtered(tt-1,1:3)' + dd_REE * rho_REE * [S_filtered(tt-1,4:5),0]';


fore_error1(1)=sqrt( (S_filtered(tt,1)'-fore1(1)).^2);
fore_error2(1)=sqrt( (S_filtered(tt,1)'-fore2(1)).^2);
% 
fore_error1(2)=sqrt( (S_filtered(tt,2)'-fore1(2)).^2);
fore_error2(2)=sqrt( (S_filtered(tt,2)'-fore2(2)).^2);
% 
FE1= (fore_error1(1)+fore_error1(2));
FE2= (fore_error2(1)+fore_error2(2));

fitness1(tt) = -(1-memory)*FE1 +memory* fitness1(tt-1); 
fitness2(tt) = -(1-memory)*FE2 +memory* fitness2(tt-1);  



n1(tt) = exp(intensity*fitness1(tt))/ (exp(intensity*fitness1(tt)) + exp(intensity*fitness2(tt))    );
n2(tt) = exp(intensity*fitness2(tt))/ (exp(intensity*fitness1(tt)) + exp(intensity*fitness2(tt))    );

% alpha1_old = alpha1;
% beta1_old = beta1;

alpha1_old = alpha1;
beta1_old = beta1;
rr_old = rr1;

data_new = S_filtered(tt,1:3)';
data_old = [1,S_filtered(tt-1,1:3)]';

[alpha1(1:3) beta1(1:3,1:3) rr1(:,:,1)] =...
          msv_learning(data_new,data_old,...
       alpha1(1:3),beta1(1:3,1:3),rr1(:,:,1),gain_y); 

   
%================================projection facility 
%PLM is allowed to have explosive roots 
% root_PLM(tt) = abs(eigs(beta1,1));

%store old ALM matrices

% gamma1_1_old = gamma1_1; 
% gamma1_2_old = gamma1_2; 
% gamma1_3_old = gamma1_3; 
% gamma1_4_old = gamma1_4; 
% 
% gamma2_1_old = gamma2_1;
% gamma2_2_old = gamma2_2;
% gamma2_3_old = gamma2_3;
% gamma2_4_old = gamma2_4;
% 
% gamma3_1_old = gamma3_1;
% gamma3_2_old = gamma3_2;
% gamma3_3_old = gamma3_3;
% gamma3_4_old = gamma3_4;

% update the system matrices
%Taylor rule, VAR-learning
[gamma1_1, gamma2_1, gamma3_1, E1, F1]=NKPC_sysmat_regime1(param(:,1),beta1,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,tt,r_bar1,r_bar2);

%Taylor rule, MSV solution
[gamma1_2, gamma2_2, gamma3_2, E2, F2]=NKPC_sysmat_regime2(param(:,2),bb_REE,dd_REE,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,tt,r_bar1,r_bar2);

%ZLB regime, VAR-learning
[gamma1_3, gamma2_3, gamma3_3, E3, F3]=NKPC_sysmat_regime3(param(:,3),beta1,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,tt,r_bar1,r_bar2);

%ZLB regime, MSV solution 
[gamma1_4, gamma2_4, gamma3_4, E4, F4]=NKPC_sysmat_regime4(param(:,4),bb_REE,dd_REE,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,tt,r_bar1,r_bar2);


%check the regime specific roots
% root_ALM1 = abs(eigs(gamma1_1,1));
% root_ALM2 = abs(eigs(gamma1_2,1));
% root_ALM3 = abs(eigs(gamma1_3,1));
% root_ALM4 = abs(eigs(gamma1_4,1));

%check the "active" system root
% root_ALM(tt) = root_ALM1 * pp_filtered(tt,1) + root_ALM2 * pp_filtered(tt,2) + root_ALM3 * pp_filtered(tt,3) + root_ALM4 * pp_filtered(tt,4);
% 

% if root_ALM(tt) > 1 
%     projectionFlag(tt) = 1;
%     
% gamma1_1 = gamma1_1_old; 
% gamma1_2 = gamma1_2_old; 
% gamma1_3 = gamma1_3_old; 
% gamma1_4 = gamma1_4_old; 
% 
% gamma2_1 = gamma2_1_old;
% gamma2_2 = gamma2_2_old;
% gamma2_3 = gamma2_3_old;
% gamma2_4 = gamma2_4_old;
% 
% gamma3_1 = gamma3_1_old;
% gamma3_2 = gamma3_2_old;
% gamma3_3 = gamma3_3_old;
% gamma3_4 = gamma3_4_old;   
% 
% end


%    alpha1_tt(:,tt)=alpha1(1:3);
%    beta1_tt(:,:,tt)=beta1(1:3,1:3);
%    rr1_tt(:,:,:,1) = rr1;



 end
likl=-sum(log(likl(burn_in+1:end)));

  end
