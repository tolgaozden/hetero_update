clear;clc;
% rng(1);
% load estimation_results_march15;
load estimation_results_march15.mat;
load counterfactual_initials.mat;
% fixed_length=110;
counterfactual_start=110;


para_names = {'pi_bar(1)','r_bar(2)','kappa(3)','tau(4)',...
    'phi_pi(5)','phi_y(6)','phi_dy(7)','rho_y(8)','rho_pi(9)','rho_r(10)',...
    'eta_y(11)','eta_pi(12)','eta_r(13)','iota_y(14)','iota_p(15)',...
    'r_bar_zlb(16)','eta_r_zlb(17)','1-p_11(18)','1-p_22(19)','gain_y(20)','memory(21)','intensity(22)'};
parameters=x;
% parameters(1)=-0.41;
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
table(para_names',parameters)




zlb_threshold=107;
zlb_threshold2=135;



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
numExo=3;
numObs=3;
numRegimes=2;
T = length(S_filtered);



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


 [beta_init,rr_init,bb_REE,dd_REE,gam1_rec_REE,gam3_rec_REE, gam0_moments,gam1_moments,autocorr_REE,rho_REE]=...
     REE_initialize_beliefs(param(:,1),Sigma1(1:3,1:3));


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


%----------------------------------------------------------------------------
intercept1=zeros(numVar,1);
intercept2=zeros(numVar,1);
intercept3=zeros(numVar,1);
intercept4=zeros(numVar,1);

% 
intercept3(3)=-(r_bar1-r_bar2);
intercept4(3)=-(r_bar1-r_bar2);


% % iid shocks, to be used over the counterfactual period
% eta1=mvnrnd(zeros(numExo,1),(Sigma1),T);
% % eta1(counterfactual_start:counterfactual_start+0) = 0.2 * ones(1,1);
% % eta2=mvnrnd(zeros(numExo,1),Sigma2,T);
% eta2=eta1;
% eta3=mvnrnd(zeros(numExo,1),(Sigma3),T);
% % eta3=eta1;
% eta3(:,1:2) = eta1(:,1:2);
% % eta4=mvnrnd(zeros(numExo,1),sqrt(Sigma4),T);
% eta4=eta3;
% eta4(:,1:2) = eta1(:,1:2);
% 
eta1 = shocks_filtered(:,:,1);
eta2 = shocks_filtered(:,:,2);
eta3 = shocks_filtered(:,:,3);
eta4 = shocks_filtered(:,:,4);

for tt=2:T
    disp(tt)
    
if tt < counterfactual_start
    
    alpha1_old = alpha1_filtered(:,tt-1);
    beta1_old = beta1_filtered(:,:,tt-1);
    
    alpha1 = alpha1_filtered(:,tt);
    beta1 = beta1_filtered(:,:,tt);
    rr1 = squeeze(rr1_filtered(:,:,1,tt));
    n1(tt) = n1_filtered(tt); 
    n2(tt) = n2_filtered(tt);
    PP(:,tt) = pp_filtered(tt,:); 
    shadow_rate(tt) = shadow_rate_filtered(tt);
    SS(:,tt) =  S_filtered(tt,:);
    fitness1(tt) = fitness1_filtered(tt);
    fitness2(tt) = fitness2_filtered(tt);
 
    
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
 

Q = [q_11,q_12,q_13 q_14;q_21,q_22,q_23 q_24; q_31,q_32,q_33 q_34; q_41 q_42 q_43 q_44];%current period transition matrix 


%update system matrices
[gamma1_1, gamma2_1, gamma3_1, E1, F1]=NKPC_sysmat_regime1(param(:,1),beta1,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,tt,r_bar1,r_bar2);

%Taylor rule, MSV solution
[gamma1_2, gamma2_2, gamma3_2, E2, F2]=NKPC_sysmat_regime2(param(:,2),bb_REE,dd_REE,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,tt,r_bar1,r_bar2);

%ZLB regime, VAR-learning
[gamma1_3, gamma2_3, gamma3_3, E3, F3]=NKPC_sysmat_regime3(param(:,3),beta1,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,tt,r_bar1,r_bar2);

%ZLB regime, MSV solution 
[gamma1_4, gamma2_4, gamma3_4, E4, F4]=NKPC_sysmat_regime4(param(:,4),bb_REE,dd_REE,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,tt,r_bar1,r_bar2);

    
%==============================================================================   
else %counterfactual period starts
    
    
    
    
    
%==========================================================   
%iterate with regime 1, obtain the shadow rate
[gamma1_1, gamma2_1, gamma3_1, E1, F1]=NKPC_sysmat_regime1(param(:,1),beta1,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,tt,r_bar1,r_bar2);
[gamma1_2, gamma2_2, gamma3_2, E2, F2]=NKPC_sysmat_regime2(param(:,2),bb_REE,dd_REE,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,tt,r_bar1,r_bar2);

S_aux =n1(tt-1)*( gamma2_1 + gamma1_1 * SS(:,tt-1) + gamma3_1 * eta1(tt,:)' ) + ...
       n2(tt-1)*( gamma2_2 + gamma1_2 * SS(:,tt-1) + gamma3_2 * eta2(tt,:)' ) ;

shadow_rate(tt) = S_aux(9);


%==========================================================   
    
%==========================================================   
%update the regime probabilities
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
 

Q = [q_11,q_12,q_13 q_14;q_21,q_22,q_23 q_24; q_31,q_32,q_33 q_34; q_41 q_42 q_43 q_44];%current period transition mat

%current period regime probabilities
PP(:,tt) = sum(  repmat(PP(:,tt-1), [1 4]) .* Q );


%==========================================================  
%iterate forward

 SS(:,tt) = PP(1,tt) * (intercept1 + gamma2_1 + gamma1_1 * SS(:,tt-1) + gamma3_1 * eta1(tt,:)') + ...
            PP(2,tt) * (intercept2 + gamma2_2 + gamma1_2 * SS(:,tt-1) + gamma3_2 * eta2(tt,:)') + ...
            PP(3,tt) * (intercept3 + gamma2_3 + gamma1_3 * SS(:,tt-1) + gamma3_3 * eta3(tt,:)') + ...
            PP(4,tt) * (intercept4 + gamma2_4 + gamma1_4 * SS(:,tt-1) + gamma3_4 * eta4(tt,:)') ; 

%==========================================================   
  %agent fractions
fore1= alpha1_old(1:3)+beta1_old(1:3,1:3)*SS(1:3,tt-1);
fore2= bb_REE * SS(1:3,tt-1) + dd_REE * rho_REE * [SS(4:5,tt-1);0];


fore_error1(1,tt)=sqrt( (SS(1,tt)'-fore1(1)).^2);
fore_error2(1,tt)=sqrt( (SS(1,tt)'-fore2(1)).^2);
% 
fore_error1(2,tt)=sqrt( (SS(2,tt)'-fore1(2)).^2);
fore_error2(2,tt)=sqrt( (SS(2,tt)'-fore2(2)).^2);
% 
FE1= (fore_error1(1,tt)+fore_error1(2,tt));
FE2= (fore_error2(1,tt)+fore_error2(2,tt));

fitness1(tt) = -(1-memory)*FE1 +memory* fitness1(tt-1); 
fitness2(tt) = -(1-memory)*FE2 +memory* fitness2(tt-1);  


% n1(tt)=0;
% n2(tt)=1;
n1(tt) = exp(intensity*fitness1(tt))/ (exp(intensity*fitness1(tt)) + exp(intensity*fitness2(tt))    );
n2(tt) = exp(intensity*fitness2(tt))/ (exp(intensity*fitness1(tt)) + exp(intensity*fitness2(tt))    );
%==========================================================  
%learning block 

alpha1_old = alpha1;
beta1_old = beta1;
rr_old = rr1;

data_new = SS(1:3,tt);
data_old = [1;SS(1:3,tt-1)];

[alpha1(1:3) beta1(1:3,1:3) rr1(:,:,1)] =...
          msv_learning(data_new,data_old,...
       alpha1(1:3),beta1(1:3,1:3),rr1(:,:,1),gain_y); 

%update matrices and check for projection facility   
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
% root_ALM1(tt) = abs(eigs(gamma1_1,1));
% root_ALM2(tt) = abs(eigs(gamma1_2,1));
% root_ALM3(tt) = abs(eigs(gamma1_3,1));
% root_ALM4(tt) = abs(eigs(gamma1_4,1));

%check the "active" system root
%  root_ALM(tt) = root_ALM1(tt) * PP(1,tt) + root_ALM2(tt) * PP(2,tt) + root_ALM3(tt) * PP(3,tt) + root_ALM4(tt) * PP(4,tt);
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


   alpha1_tt(:,tt)=alpha1(1:3);
   beta1_tt(:,:,tt)=beta1(1:3,1:3);
   rr1_tt(:,:,:,1) = rr1;



end

end


figure;
plot(S_filtered(2:end,1));
hold on;
plot(SS(1,2:end));
legend('actual','counterfactual');
title('output gap');
% 
% figure;
% plot(S_filtered(2:end,2));
% hold on;
% plot(SS(2,2:end));
% legend('actual','counterfactual');
% title('inflation');

figure;
plot(S_filtered(2:end,4));
hold on;
plot(SS(4,2:end));
legend('actual','counterfactual');
title('exogenous shock--output gap');
% 
% figure;
% plot(S_filtered(2:end,5));
% hold on;
% plot(SS(5,2:end));
% legend('actual','counterfactual');
% title('exogenous shock--inflation');


% figure;
% plot(S_filtered(2:end,3));
% hold on;
% plot(SS(3,2:end));
% legend('actual','counterfactual');
% title('nominal rates');


% figure;
% plot(shadow_rate_filtered(2:end));
% hold on;
% plot(shadow_rate(2:end));
% hold on;
% plot(ones(length(shadow_rate(2:end)),1)*(-r_bar1+r_bar2));
% legend('estimated','counterfactual');
% title('shadow_rate');
% % 
% figure;
% plot(n1_filtered(2:end));
% hold on;
% plot(n1(2:end));
% legend('estimated','counterfactual');
% title('fraction--learning');



figure;
subplot(3,2,1);
area(PP(1,:));

subplot(3,2,2);
area(PP(2,:));

subplot(3,2,3);
area(PP(3,:));

subplot(3,2,4);
area(PP(4,:));

subplot(3,2,5);
area(PP(1,:)+PP(2,:));
ylim([0 1]);

subplot(3,2,6);
area(PP(3,:)+PP(4,:));
ylim([0 1]);

% 
% figure;
% plot(projectionFlag);
