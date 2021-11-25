clear;clc;
% load estimation_results_march15
load mcmc_results_final2;
parameters=posteriorMean';
para_names = {'pi_bar(1)','r_bar(2)','kappa(3)','tau(4)',...
    'phi_pi(5)','phi_y(6)','phi_dy(7)','rho_y(8)','rho_pi(9)','rho_r(10)',...
    'eta_y(11)','eta_pi(12)','eta_r(13)','iota_y(14)','iota_p(15)',...
    'r_bar_zlb(16)','eta_r_zlb(17)','1-p_11(18)','1-p_22(19)','gain_y(20)'};
% parameters=x;
% parameters=x;
% parameters(1)=0;
THETA1=1;
THETA2=1;
PHI1=parameters(18)*100;
PHI2=parameters(19)*100;

r_bar1 = parameters(2);
r_bar2 = parameters(16);
pi_bar = parameters(1);

y_bar = 0;

parameters=vec(parameters);
table(para_names',parameters)



load('us_dataset_survey.mat');
first_obs=4;
burn_in=4;
%first_obs=164;burn_in=4;
%dataset=[gap_detrend2,pinfobs,robs,gap_exp_fore,pinf_mean_fore];
dataset=[gap_detrend2,pinfobs,robs];
dataset=dataset(first_obs:end,:);

% load('final_dataset.mat');
% first_obs=64;
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


%r_bar for ZLB and forward guidance regimes
param(2,2)=parameters(16);


%eta_r for ZLB and forward guidance regimes
param(13,2)=parameters(17);


%monetary policy parameters for FG and ZLB regimes--inactive taylor rule
param(5,2)=0;param(6,2)=0;param(7,2) = 0;param(10,2)=0;

gain_y=parameters(20);
% gain_pinf=parameters(21);
% gain_r = parameters(25);
gain_r = 0.001;

% gain_vec = [gain_y gain_pinf gain_r]';

phi_pi_taylor = parameters(5);
phi_y_taylor = parameters(6);
phi_dy_taylor = parameters(7);
rho_r_taylor = parameters(10);
   
Q = [ 0.987 1-0.987; 
    1-0.964 0.964];
    



q_11 = Q(1,1);
q_12 = Q(1,2);
q_21 = Q(2,1);
q_22 = Q(2,2);


numVar=9;
numExo=2;
numObs=3;
numRegimes=2;
T=size(dataset,1);l=3;


Sigma1=diag([param(end-4,1)^2;param(end-3,1)^2;param(end-2,1)^2]);
Sigma2=diag([param(end-4,2)^2;param(end-3,2)^2;param(end-2,2)^2]);

  alpha1=0*ones(numVar,1);
  beta1=0*eye(numVar);
%   rr1=zeros(4,4,2);
%  load('VAR1_initial_beliefs.mat');
load('AR1_initial_beliefs.mat');
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


%ZLB regime, VAR-learning
[gamma1_2, gamma2_2, gamma3_2, E2, F2]=NKPC_sysmat_regime3(param(:,2),beta1,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,1,r_bar1,r_bar2);






H1=0.0*diag(var(dataset(1:zlb_threshold,:)));
H2=0.0*diag(var(dataset(1:zlb_threshold,:)));



S_fore11=zeros(numVar,1);
S_fore12=zeros(numVar,1);
S_fore21=zeros(numVar,1);
S_fore22=zeros(numVar,1);


P_fore11=zeros(numVar,numVar);
P_fore12=zeros(numVar,numVar);

P_fore21=zeros(numVar,numVar);
P_fore22=zeros(numVar,numVar);


v11=zeros(numObs,1);
v12=zeros(numObs,1);


Fe11=zeros(numObs,numObs);
Fe12=zeros(numObs,numObs);

Fe21=zeros(numObs,numObs);
Fe22=zeros(numObs,numObs);


S_upd11=zeros(numVar,1);
S_upd12=zeros(numVar,1);

S_upd21=zeros(numVar,1);
S_upd22=zeros(numVar,1);



P_upd11=zeros(numVar,numVar);
P_upd12=zeros(numVar,numVar);
P_upd21=zeros(numVar,numVar);
P_upd22=zeros(numVar,numVar);


ml11=0;
ml12=0;

ml21=0;
ml22=0;
likl=zeros(T,1);

pp_fore11=1;pp_fore12=0;
pp_fore21=0;pp_fore22=0;

pp_upd11=1;pp_upd12=0;
pp_upd21=0;pp_upd22=0;

pp_collapse1=0.5;pp_collapse2=0.5;
pp_filtered=0*ones(T,2);

S_collapse1=zeros(numVar,1);S_collapse2=zeros(numVar,1);
P_collapse1=10*eye(numVar);P_collapse2=10*eye(numVar);
S_filtered=zeros(T,numVar);


%----------------------------------------------------------------------------
intercept1=zeros(numVar,1);
intercept2=zeros(numVar,1);


intercept2(3)=-(r_bar1-r_bar2);



S_collapse1(1) = dataset(1,1);
S_collapse1(2) = dataset(1,2)-parameters(2);
S_collapse1([3 8 9]) = dataset(1,3) - parameters(3);

S_collapse2(1) = dataset(1,1);
S_collapse2(2) = dataset(1,2)-parameters(2);
S_collapse2([3 8 9]) = dataset(1,3) - parameters(3);





shadow_rate =zeros(T,1);
shadow_rate(1) = dataset(1,3);



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

S_fore21=intercept1+gamma1_1*S_collapse2+gamma2_1;%
S_fore22=intercept2+gamma1_2*S_collapse2+gamma2_2;%

%
P_fore11=gamma1_1*P_collapse1*gamma1_1'+gamma3_1*Sigma1*gamma3_1';
P_fore12=gamma1_2*P_collapse1*gamma1_2'+gamma3_2*Sigma2*gamma3_2';  


P_fore21=gamma1_1*P_collapse2*gamma1_1'+gamma3_1*Sigma1*gamma3_1';
P_fore22=gamma1_2*P_collapse2*gamma1_2'+gamma3_2*Sigma2*gamma3_2';


v11=x_tt-E1-F1*S_fore11;
v12=x_tt-E1-F2*S_fore12;


v21=x_tt-E1-F1*S_fore21;
v22=x_tt-E1-F2*S_fore22;

%
Fe11=F1*P_fore11*F1'+H1;
Fe12=F2*P_fore12*F2'+H2;

Fe21=F1*P_fore21*F1'+H1;
Fe22=F2*P_fore22*F2'+H2;


%
S_upd11=S_fore11+P_fore11*F1'*(Fe11^(-1))*v11;
S_upd12=S_fore12+P_fore12*F2'*(Fe12^(-1))*v12;


S_upd21=S_fore21+P_fore21*F1'*(Fe21^(-1))*v21;
S_upd22=S_fore22+P_fore22*F2'*(Fe22^(-1))*v22;


 S_upd_all(:,:,tt) = [S_upd11 S_upd12  ...
     S_upd21 S_upd22];


shadow_rate(tt) = S_upd11(9);
% 
 q_taylor(tt)=THETA1/(THETA1+exp(-PHI1*(shadow_rate(tt)+(r_bar1-r_bar2))));
 q_zlb(tt)=THETA2/(THETA2+exp(+PHI2*(shadow_rate(tt))+(r_bar1-r_bar2)));
 
 
 q_11= q_taylor(tt);
 q_12 =1-q_taylor(tt);
 q_21 = 1-q_zlb(tt) ; 
 q_22 = q_zlb(tt);
 



Q = [q_11,q_12;q_21,q_22];

%
P_upd11=(eye(numVar)-P_fore11*F1'*Fe11^(-1)*F1)*P_fore11;    
P_upd12=(eye(numVar)-P_fore12*F2'*Fe12^(-1)*F2)*P_fore12;  


P_upd21=(eye(numVar)-P_fore21*F1'*Fe21^(-1)*F1)*P_fore21;  
P_upd22=(eye(numVar)-P_fore22*F2'*Fe22^(-1)*F2)*P_fore22;  

%
pp_fore11=q_11*pp_collapse1;
pp_fore12=q_12*pp_collapse1;

pp_fore21=q_21*pp_collapse2;
pp_fore22=q_22*pp_collapse2;


%
ml11=(2*pi)^(-l/2)*det(Fe11)^(-0.5)*exp(-0.5*v11'*Fe11^(-1)*v11);
ml12=(2*pi)^(-l/2)*det(Fe12)^(-0.5)*exp(-0.5*v12'*Fe12^(-1)*v12);


ml21=(2*pi)^(-l/2)*det(Fe21)^(-0.5)*exp(-0.5*v21'*Fe21^(-1)*v21);
ml22=(2*pi)^(-l/2)*det(Fe22)^(-0.5)*exp(-0.5*v22'*Fe22^(-1)*v22);


% 
likl(tt)=ml11*pp_fore11+    ml12*pp_fore12+  ...
         ml21*pp_fore21+    ml22*pp_fore22;

ml(:,tt) = [ml11 ml12 ml21 ml22];
vv_all(:,:,tt) =[v11 v12 v21 v22 ];
%
pp_upd11=(ml11*pp_fore11)/likl(tt);
pp_upd12=(ml12*pp_fore12)/likl(tt);


pp_upd21=(ml21*pp_fore21)/likl(tt);
pp_upd22=(ml22*pp_fore22)/likl(tt);



pp_collapse1=pp_upd11+pp_upd21;
pp_collapse2=pp_upd12+pp_upd22;


if pp_collapse1>10e-5;
    S_collapse1=(pp_upd11*S_upd11+pp_upd21*S_upd21)/pp_collapse1;
P_collapse1=(pp_upd11*(P_upd11+(S_collapse1-S_upd11)*(S_collapse1-S_upd11)')+...
    pp_upd21*(P_upd21+(S_collapse1-S_upd21)*(S_collapse1-S_upd21)'))/pp_collapse1;
else
    S_collapse1=(S_upd11+S_upd21)/2;
    P_collapse1=(P_upd11+P_upd21)/2;
end

if pp_collapse2>10e-5
  S_collapse2=(pp_upd12*S_upd12+pp_upd22*S_upd22)/pp_collapse2;
P_collapse2=(pp_upd12*(P_upd12+(S_collapse2-S_upd12)*(S_collapse2-S_upd12)')+...
    pp_upd22*(P_upd22+(S_collapse2-S_upd22)*(S_collapse2-S_upd22)'))/pp_collapse2;
else
    S_collapse2=(S_upd12+S_upd22)/2;
    P_collapse2=(P_upd12+P_upd22)/2;
end



%

S_filtered(tt,:)=pp_collapse1*S_collapse1+pp_collapse2*S_collapse2;
S_collapse1_all(:,tt) = S_collapse1;
S_collapse2_all(:,tt) = S_collapse2;


pp_filtered(tt,:)=[pp_collapse1,pp_collapse2];




alpha1_old = alpha1;
beta1_old = beta1;
rr_old = rr1;

for jj=1:2

data_new = S_filtered(tt,jj)';
data_old = [1,S_filtered(tt-1,jj)]';

[alpha1(jj) beta1(jj,jj) rr1(:,:,jj)] =...
          msv_learning(data_new,data_old,...
       alpha1(jj),beta1(jj,jj),rr1(:,:,jj),gain_y); 
end


%================================projection facility 
%PLM is allowed to have explosive roots 
% root_PLM(tt) = abs(eigs(beta1,1));

%store old ALM matrices

gamma1_1_old = gamma1_1; 
gamma1_2_old = gamma1_2; 


gamma2_1_old = gamma2_1;
gamma2_2_old = gamma2_2;


% update the system matrices
%Taylor rule, VAR-learning
[gamma1_1, gamma2_1, gamma3_1, E1, F1]=NKPC_sysmat_regime1(param(:,1),beta1,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,tt,r_bar1,r_bar2);


%ZLB regime, VAR-learning
[gamma1_2, gamma2_2, gamma3_2, E2, F2]=NKPC_sysmat_regime3(param(:,2),beta1,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,tt,r_bar1,r_bar2);



%check the regime specific roots
% root_ALM1 = abs(eigs(gamma1_1,1));
% root_ALM2 = abs(eigs(gamma1_2,1));


% %check the "active" system root
% root_ALM(tt) = root_ALM1 * pp_filtered(tt,1) + root_ALM2 * pp_filtered(tt,2);
% root_ALM(tt) = max(root_ALM1,root_ALM2);
% root_ALM = 

% 
% if root_ALM(tt) > 1 
%     projectionFlag(tt) = 1;
%     
% gamma1_1 = gamma1_1_old; 
% gamma1_2 = gamma1_2_old; 
% 
% 
% gamma2_1 = gamma2_1_old;
% gamma2_2 = gamma2_2_old;
% 
% 
% end


   alpha1_tt(:,tt)=alpha1(1:3);
   beta1_tt(:,:,tt)=beta1(1:3,1:3);
   rr1_tt(:,:,:,1) = rr1;



end
 
save kf_output_workspace_2regime.mat;
% % 
% % likl=-sum(log(likl(burn_in+1:end)));
% 
% 
% 
% 
% % figure('Name','Interest Rate and Regime Probability');
% %  plot(Date,dataset(2:end,3),'--');
% % hold on;
% % plot(Date,ones(T-1,1)-pp_filtered(2:end,1),'lineWidth',3,'color','black');
% % hold on;
% % plot(Date,pp_filtered(2:end,2),'lineWidth',3,'color','black');
% % hold on;
% % plot(Date,pp_filtered(2:end,3),'lineWidth',3,'color','black');
% % 
% % xlim([startDate endDate])
% % datetick('x','yyyy','keeplimits');
% % fig = gcf;
% % fig.PaperPositionMode = 'auto'
% % fig_pos = fig.PaperPosition;
% % fig.PaperSize = [fig_pos(3) fig_pos(4)];
% % print(fig,'NKPC_ree_init_VAR1_regime','-dpdf');
% 
% % figure('Name','Regime Probability');
% % area(Date,1-pp_filtered(2:end,1));
% % xlim([startDate endDate])
% % datetick('x','yyyy','keeplimits');
% % fig = gcf;
% % fig.PaperPositionMode = 'auto'
% % fig_pos = fig.PaperPosition;
% % fig.PaperSize = [fig_pos(3) fig_pos(4)];
% % print(fig,'NKPC_ree_init_VAR1_regimeProb','-dpdf');
% 
% figure('Name','Learning: Intercepts');
% subplot(3,1,1);
% plot(Date,alpha1_tt(1,2:end),'lineWidth',3,'color','black');
% % hold on;
% % plot(Date,alpha2_tt(1,2:end),'lineWidth',3,'color','red');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% subplot(3,1,2);
% plot(Date,alpha1_tt(2,2:end),'lineWidth',3,'color','black');
% hold on;
% % hold on;
% % plot(Date,alpha2_tt(2,2:end),'lineWidth',3,'color','red');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% subplot(3,1,3);
% plot(Date,alpha1_tt(3,2:end),'lineWidth',3,'color','black');
% hold on;
% % hold on;
% % plot(Date,alpha2_tt(3,2:end),'lineWidth',3,'color','red');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% fig = gcf;
% fig.PaperPositionMode = 'auto'
% fig_pos = fig.PaperPosition;
% fig.PaperSize = [fig_pos(3) fig_pos(4)];
% print(fig,'NKPC_ree_init_VAR1_alphas','-dpdf');
% 
% % figure('Name','Learning: First-order autocorrelation','units','normalized','outerposition',[0 0 1 1]);
% figure('Name','Learning: First-order autocorrelation');
% subplot(3,3,1);
% plot(Date,squeeze(beta1_tt(1,1,2:end)),'lineWidth',3,'color','black');
% % hold on;
% % plot(Date,squeeze(beta2_tt(1,1,2:end)),'lineWidth',3,'color','red');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% 
% subplot(3,3,2);
% plot(Date,squeeze(beta1_tt(1,2,2:end)),'lineWidth',3,'color','black');
% % hold on;
% % plot(Date,squeeze(beta2_tt(1,2,2:end)),'lineWidth',3,'color','red');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% 
% subplot(3,3,3);
% plot(Date,squeeze(beta1_tt(1,3,2:end)),'lineWidth',3,'color','black');
% % hold on;
% % plot(Date,squeeze(beta2_tt(1,3,2:end)),'lineWidth',3,'color','red');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% 
% subplot(3,3,4);
% plot(Date,squeeze(beta1_tt(2,1,2:end)),'lineWidth',3,'color','black');
% % hold on;
% % plot(Date,squeeze(beta2_tt(2,1,2:end)),'lineWidth',3,'color','red');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% 
% subplot(3,3,5);
% plot(Date,squeeze(beta1_tt(2,2,2:end)),'lineWidth',3,'color','black');
% hold on;
% % plot(Date,squeeze(beta2_tt(2,2,2:end)),'lineWidth',3,'color','red');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% 
% subplot(3,3,6);
% plot(Date,squeeze(beta1_tt(2,3,2:end)),'lineWidth',3,'color','black');
% hold on;
% % plot(Date,squeeze(beta2_tt(2,3,2:end)),'lineWidth',3,'color','red');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% 
% subplot(3,3,7);
% plot(Date,squeeze(beta1_tt(3,1,2:end)),'lineWidth',3,'color','black');
% hold on;
% % plot(Date,squeeze(beta2_tt(3,1,2:end)),'lineWidth',3,'color','red');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% 
% subplot(3,3,8);
% plot(Date,squeeze(beta1_tt(3,2,2:end)),'lineWidth',3,'color','black');
% hold on;
% % plot(Date,squeeze(beta2_tt(3,2,2:end)),'lineWidth',3,'color','red');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% 
% subplot(3,3,9);
% plot(Date,squeeze(beta1_tt(3,3,2:end)),'lineWidth',3,'color','black');
% hold on;
% % plot(Date,squeeze(beta2_tt(3,3,2:end)),'lineWidth',3,'color','red');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% 
% % fig = gcf;
% % fig.PaperPositionMode = 'auto'
% % fig_pos = fig.PaperPosition;
% % fig.PaperSize = [fig_pos(3) fig_pos(4)];
% % print(fig,'NKPC_ree_init_VAR1_betas','-dpdf');
% 
% 
% % figure;
% % subplot(3,1,1);
% % plot(S_filtered(:,8));
% % hold on;
% % plot(S_filtered(:,3));
% % title('shadow rate lagged on its own past');
% % subplot(3,1,2);
% % plot(S_filtered(:,9));
% % hold on;
% % plot(S_filtered(:,3));
% % title('shadow rate lagged on nominal rate');
% % subplot(3,1,3);
% % plot(shadow_rate(2:end));
% % hold on;
% % plot(dataset(2:end,3));
% % hold on;
% % plot(S_filtered(2:end,8));
% % legend('shadow','3','8');
% 
% % figure;
% % subplot(2,1,1);
% % plot(q_taylor);
% % subplot(2,1,2);
% % plot(q_zlb);
% 
% 
% figure;
% subplot(2,1,1);
% area(Date,pp_filtered(2:end,1));
% title('VAR learning, Taylor rule');
% datetick('x','yyyy','keeplimits');
% ylim([0 1]);
% xlim([startDate endDate]);
% 
% subplot(2,1,2);
% area(Date,pp_filtered(2:end,2));
% title('VAR learning, ZLB');
% datetick('x','yyyy','keeplimits');
% ylim([0 1]);
% xlim([startDate endDate]);
% 
% 
% 
% % figure('Name','Projection Facility','units','normalized','outerposition',[0 0 1 1]);
% % subplot(3,1,1);
% % plot(Date,pr_flag(2:end),'color','black');
% % title('projection facility');
% % xlim([startDate endDate])
% % datetick('x','yyyy','keeplimits');
% % subplot(3,1,2);
% % plot(Date,largest_eig1(2:end),'color','black');
% % title('largest eig regime 1');
% % xlim([startDate endDate])
% % datetick('x','yyyy','keeplimits');
% % subplot(3,1,3);
% % plot(Date,largest_eig2(2:end),'color','black');
% % title('largest eig regime 2');
% % xlim([startDate endDate])
% % datetick('x','yyyy','keeplimits');
% 
% figure;
% plot(Date,S_filtered(2:end,3));
% datetick('x','yyyy','keeplimits');
% xlim([startDate endDate]);
% hold on;
% plot(Date,S_filtered(2:end,9));
% datetick('x','yyyy','keeplimits');
% xlim([startDate endDate]);
% 
% 
% figure('Name','Projection Facility');
% plot(Date,projectionFlag(2:end));
% datetick('x','yyyy','keeplimits');
% xlim([startDate endDate]);
