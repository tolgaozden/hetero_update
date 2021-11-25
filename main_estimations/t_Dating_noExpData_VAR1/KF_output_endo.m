clear;clc;%close all;
% load('estimation_results_march15.mat');
load estimation_results_var1.mat;
endogenous_switching=1;
THETA1=1;
THETA2=1;
PHI1=100;
PHI2=100;
%parameters=param_init;
parameters=x;
%clear;clc;close all;
%parameters=[0.06 0.97 1.34 0.036 3.13 1.32 0.35 0.38 0.05 0.98 0.74 0.26 0.33 0.04 0.02 0.02 0.10 0.005];    
%clear;clc;load('us_dataset.mat');dataset=[gap_hp,pinfobs,robs];
%dataset=dataset(44:end,:);

load('us_dataset.mat');
first_obs=44;burn_in=4;
dataset=[gap_cbo,pinfobs,robs];
dataset=dataset(first_obs:end,:);
startDate=datenum('01-01-1966');
endDate = datenum('01-12-2016');
Date=linspace(startDate,endDate,length(dataset)-1);

param(:,1)=parameters(1:15);
param(:,2)=parameters(1:15);
param(3,2)=parameters(16);
% param(12,1)=0.3;param(13,1)=0.3;
param(13,2)=parameters(17);
% param(13,2)=0.03;
param(6,2)=0;param(7,2)=0;param(10,2)=0;
q_11=1-parameters(18);q_22=1-parameters(19);
   gain=parameters(20);
Q=[q_11,1-q_11;1-q_22,q_22];
ergodic_states=[(1-q_22)/(2-q_11-q_22);(1-q_11)/(2-q_11-q_22)];
% q_11=Q(1,1);q_12=Q(1,2);q_21=Q(2,1);q_22=Q(2,2);
numVar=5;numExo=2;numObs=3;numRegimes=2;numEndo=3;
T=size(dataset,1);l=3;


%  [alpha_init beta_init rr_init]=belief_initialization(parameters,dataset);
  alpha1=0*ones(numVar,1);beta1=0*eye(numVar);rr=zeros(4,4);
 load('VAR1_initial_beliefs.mat');
alpha1(1:3)=alpha_init(1:3);
 beta1(1:3,1:3)=beta_init(1:3,1:3);
% %alpha1=alpha_init;
% %beta1=beta_init;
rr=rr_init;


[A1 B1 C1 D1, E1 F1 G1]=NKPC_sysmat_regime1(param(:,1));
[A2 B2 C2 D2 E2 F2 G2]=NKPC_sysmat_regime1(param(:,2));
A1_inv=A1^(-1);A2_inv=A2^(-1);
Sigma1=diag([param(end-4,1)^2;param(end-3,1)^2;param(end-2,1)^2]);
Sigma2=diag([param(end-4,2)^2;param(end-3,2)^2;param(end-2,2)^2]);

H1=0*diag(var(dataset(1:50,:)));H2=0*diag(var(dataset(1:end,:)));



S_fore11=zeros(numVar,1);S_fore12=zeros(numVar,1);S_fore21=zeros(numVar,1);S_fore22=zeros(numVar,1);
P_fore11=zeros(numVar,numVar);P_fore12=zeros(numVar,numVar);P_fore21=zeros(numVar,numVar);P_fore22=zeros(numVar,numVar);
v11=zeros(numObs,1);v12=zeros(numObs,1);v21=zeros(numObs,1);v22=zeros(numObs,1);
Fe11=zeros(numObs,numObs);Fe12=zeros(numObs,numObs);Fe21=zeros(numObs,numObs);Fe22=zeros(numObs,numObs);
S_upd11=zeros(numVar,1);S_upd12=zeros(numVar,1);S_upd21=zeros(numVar,1);S_upd22=zeros(numVar,1);
P_upd11=zeros(numVar,numVar);P_upd12=zeros(numVar,numVar);P_upd21=zeros(numVar,numVar);P_upd22=zeros(numVar,numVar);
ml11=0;ml12=0;ml21=0;ml22=0;
likl=zeros(T,1);
%pp_fore11=0;pp_fore12=0;pp_fore21=0;pp_fore22=0;
pp_fore11=1;pp_fore12=0;pp_fore21=0;pp_fore22=0;
pp_upd11=1;pp_upd12=0;pp_upd21=0;pp_upd22=0;
%pp_collapse1=regime(1);pp_collapse2=1-regime(1);
pp_collapse1=0.5;pp_collapse2=0.5;
S_collapse1=zeros(numVar,1);S_collapse2=zeros(numVar,1);
P_collapse1=eye(numVar);P_collapse2=eye(numVar);
q_11=Q(1,1);q_12=Q(1,2);q_21=Q(2,1);q_22=Q(2,2);
S_filtered=zeros(T,numVar);
%pp_filtered=zeros(T,1);
pp_filtered=ones(T,1);


%----------------------------------------------------------------------------
rrOld=rr;
thetaOld=[alpha1(1:3),beta1(1:3,1:3)];
pr_flag=zeros(T,1);


intercept1=zeros(numVar,1);
%intercept1=A1_inv*intercept1;
%-----
intercept2=zeros(numVar,1);
intercept2(3)=-(E1(3)-E2(3));
%intercept2(4)=(-1/parameters(5))*(E1(3)-E2(3));
%intercept2=A2_inv*intercept2;


update_matrices;

shadow_alpha=0;
shadow_beta=zeros(3,1);
shadow_rr=1;
alpha1_aux = zeros(3,1);
beta1_aux=zeros(3,4);

for tt=2:T
    


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
%    
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
%
 S_upd_all11(tt,:) = S_upd11;
 v_all11(tt,:) = v11;
 S_upd_all12(tt,:) = S_upd12;
 S_upd_all21(tt,:) = S_upd21;
 S_upd_all22(tt,:) = S_upd22;
 
 if endogenous_switching==1;
     

       if tt==2
           shadow_rate11(tt) = S_upd11(tt);
           shadow_rate12(tt) = S_upd12(tt);
           shadow_rate21(tt) = S_upd21(tt);
           shadow_rate22(tt) = S_upd22(tt);
       end
           
 [shadow_rate11,Q11  ] = calculate_shadow_rate(shadow_rate11,param,S_upd_all11,v_all11,tt,THETA1,PHI1,THETA2,PHI2);
 %[shadow_rate12,Q12  ] = calculate_shadow_rate(shadow_rate12,param,S_upd_all12,tt,THETA1,PHI1,THETA2,PHI2);
 % [shadow_rate21,Q21  ] = calculate_shadow_rate(shadow_rate21,param,S_upd_all21,tt,THETA1,PHI1,THETA2,PHI2);
 % [shadow_rate22,Q22  ] = calculate_shadow_rate(shadow_rate22,param,S_upd_all22,tt,THETA1,PHI1,THETA2,PHI2);
   
             
             
             
 end
 
%
P_upd11=(eye(numVar)-P_fore11*F1'*Fe11^(-1)*F1)*P_fore11;    
P_upd12=(eye(numVar)-P_fore12*F2'*Fe12^(-1)*F2)*P_fore12;  
P_upd21=(eye(numVar)-P_fore21*F1'*Fe21^(-1)*F1)*P_fore21;  
P_upd22=(eye(numVar)-P_fore22*F2'*Fe22^(-1)*F2)*P_fore22;  
% %
if endogenous_switching==0
pp_fore11=q_11*pp_collapse1;
pp_fore12=q_12*pp_collapse1;
pp_fore21=q_21*pp_collapse2;
pp_fore22=q_22*pp_collapse2;
else
pp_fore11=  Q11(1,1) * pp_collapse1;
pp_fore12=  Q11(1,2) * pp_collapse1;
pp_fore21=  Q11(2,1) * pp_collapse2;
pp_fore22=  Q11(2,2) * pp_collapse2;
end

%
ml11=(2*pi)^(-l/2)*det(Fe11)^(-0.5)*exp(-0.5*v11'*Fe11^(-1)*v11);
ml12=(2*pi)^(-l/2)*det(Fe12)^(-0.5)*exp(-0.5*v12'*Fe12^(-1)*v12);
ml21=(2*pi)^(-l/2)*det(Fe21)^(-0.5)*exp(-0.5*v21'*Fe21^(-1)*v21);
ml22=(2*pi)^(-l/2)*det(Fe22)^(-0.5)*exp(-0.5*v22'*Fe22^(-1)*v22);
% 
likl(tt)=ml11*pp_fore11+ml12*pp_fore12+ml21*pp_fore21+ml22*pp_fore22;
%
pp_upd11=(ml11*pp_fore11)/likl(tt);
pp_upd12=(ml12*pp_fore12)/likl(tt);
pp_upd21=(ml21*pp_fore21)/likl(tt);
pp_upd22=(ml22*pp_fore22)/likl(tt);
%
pp_collapse1=pp_upd11+pp_upd21;
pp_collapse2=pp_upd12+pp_upd22;

if pp_collapse1>10e-5;
    S_collapse1=(pp_upd11*S_upd11+pp_upd21*S_upd21)/pp_collapse1;
P_collapse1=(pp_upd11*(P_upd11+(S_collapse1-S_upd11)*(S_collapse1-S_upd11)')+...
    pp_upd21*(P_upd21+(S_collapse1-S_upd21)*(S_collapse1-S_upd21)'))/pp_collapse1;
else S_collapse1=zeros(numVar,1);
    P_collapse1=eye(numVar);
end

if pp_collapse2>10e-5
P_collapse2=(pp_upd12*(P_upd12+(S_collapse2-S_upd12)*(S_collapse2-S_upd12)')+...
    pp_upd22*(P_upd22+(S_collapse2-S_upd22)*(S_collapse2-S_upd22)'))/pp_collapse2;
S_collapse2=(pp_upd12*S_upd12+pp_upd22*S_upd22)/pp_collapse2;
else S_collapse2=zeros(numVar,1);
    P_collapse2=eye(numVar);
end

%
S_filtered(tt,:)=pp_collapse1*S_collapse1+pp_collapse2*S_collapse2;
pp_filtered(tt)=pp_collapse1;



rrOld=rr;
alphaOld=alpha1;
betaOld=beta1;



if endogenous_switching==0
    regressor = [1,S_filtered(tt-1,1:3)]';
    regressand = S_filtered(tt,1:3)';
     [alpha1(1:3) beta1(1:3,1:3) rr] =...
          msv_learning(regressand,regressor,...
       alpha1(1:3),beta1(1:3,1:3),rr,gain);
else
    if pp_filtered(tt) >0.95
        
        regressor = [1,S_filtered(tt-1,1:3)]';
    regressand = S_filtered(tt,1:3)';
     [alpha1(1:3) beta1(1:3,1:3) rr] =...
          msv_learning(regressand,regressor,...
       alpha1(1:3),beta1(1:3,1:3),rr,gain);
   
    else
            regressor = [1,S_filtered(tt-1,1:3),shadow_rate11(tt-1)]';
    regressand = S_filtered(tt,1:3)';
    
   alpha_temp=[alpha1(1:3)];
   beta_temp = [beta1(1:3,1:3)];
   beta_temp(4,:)=shadow_beta;
   rr_temp = rr;
   rr_temp(5,5) = shadow_rr;
    
     [alpha1_aux beta1_aux rr_aux] =...
          msv_learning(regressand,regressor,...
       alpha_temp,beta_temp,rr_temp,gain);   
   
   alpha1(1:3) = alpha1_aux(1:3);
   beta1(1:3,1:3) = beta1_aux(1:3,1:3);
   rr(1:4,1:4) = rr_aux(1:4,1:4);
   
%    shadow_alpha = alpha_aux(4);
   shadow_beta = beta1_aux(:,4);
   shadow_rr = rr_aux(5,5);
   
    end
    
end
    


   

update_matrices;

try;largest_eig1(tt)=abs(eigs(gamma1_1,1));catch;largest_eig1(tt)=1.01;end;
try;largest_eig2(tt)=abs(eigs(gamma1_2,1));catch;largest_eig1(tt)=1.01;end;
% eig_average(tt)=largest_eig1(tt)*ergodic_states(1)+largest_eig2(tt)*ergodic_states(2);
eig_average(tt)=largest_eig1(tt)*pp_filtered(tt)+largest_eig2(tt)*(1-pp_filtered(tt));

%if eig_average(tt)>1 || largest_eig1(tt)>1 || largest_eig2(tt)>1 
if eig_average(tt)>1

    alpha1=alphaOld;
    beta1=betaOld;
    rr=rrOld;

 update_matrices;
 
    pr_flag(tt)=1;
end
% 
%    alpha_tt(:,tt)=alpha1(1:3);
%    beta_tt(:,:,tt)=beta1(1:3,1:3);
alpha_tt(:,tt) = alpha1_aux;
beta_tt(:,:,tt) = beta1_aux;
   
   rr_tt(:,:,tt)=rr;
   rr_tt_inv(:,:,tt)=rr^(-1);
   efficient_gain(:,:,tt)=gain*rr_tt_inv(:,:,tt);

end

 
likl=-sum(log(likl(burn_in+1:end)));

% figure;
% subplot(3,1,1);
% plot(squeeze(rr_tt(2,2,:)));
% subplot(3,1,2);
% plot(squeeze(rr_tt(3,3,:)));
% subplot(3,1,3);
% plot(squeeze(rr_tt(4,4,:)));



% figure('Name','Interest Rate and Regime Probability','units','normalized','outerposition',[0 0 1 1]);
%  plot(Date,dataset(2:end,3),'--');
% hold on;
% plot(Date,ones(T-1,1)-pp_filtered(2:end),'lineWidth',3,'color','black');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% fig = gcf;
% fig.PaperPositionMode = 'auto'
% fig_pos = fig.PaperPosition;
% fig.PaperSize = [fig_pos(3) fig_pos(4)];
% print(fig,'NKPC_ree_init_VAR1_regime','-dpdf');
% 
% figure('Name','Regime Probability','units','normalized','outerposition',[0 0 1 1]);
% area(Date,1-pp_filtered(2:end));
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% fig = gcf;
% fig.PaperPositionMode = 'auto'
% fig_pos = fig.PaperPosition;
% fig.PaperSize = [fig_pos(3) fig_pos(4)];
% print(fig,'NKPC_ree_init_VAR1_regimeProb','-dpdf');
% 
% figure('Name','Learning: Intercepts','units','normalized','outerposition',[0 0 1 1]);
% subplot(3,1,1);
% plot(Date,alpha_tt(1,2:end),'lineWidth',3,'color','black');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% subplot(3,1,2);
% plot(Date,alpha_tt(2,2:end),'lineWidth',3,'color','black');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% subplot(3,1,3);
% plot(Date,alpha_tt(3,2:end),'lineWidth',3,'color','black');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% fig = gcf;
% fig.PaperPositionMode = 'auto'
% fig_pos = fig.PaperPosition;
% fig.PaperSize = [fig_pos(3) fig_pos(4)];
% print(fig,'NKPC_ree_init_VAR1_alphas','-dpdf');
% 
% figure('Name','Learning: First-order autocorrelation','units','normalized','outerposition',[0 0 1 1]);
% subplot(3,3,1);
% plot(Date,squeeze(beta_tt(1,1,2:end)),'lineWidth',3,'color','black');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% 
% subplot(3,3,2);
% plot(Date,squeeze(beta_tt(1,2,2:end)),'lineWidth',3,'color','black');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% 
% subplot(3,3,3);
% plot(Date,squeeze(beta_tt(1,3,2:end)),'lineWidth',3,'color','black');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% 
% subplot(3,3,4);
% plot(Date,squeeze(beta_tt(2,1,2:end)),'lineWidth',3,'color','black');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% 
% subplot(3,3,5);
% plot(Date,squeeze(beta_tt(2,2,2:end)),'lineWidth',3,'color','black');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% 
% subplot(3,3,6);
% plot(Date,squeeze(beta_tt(2,3,2:end)),'lineWidth',3,'color','black');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% 
% subplot(3,3,7);
% plot(Date,squeeze(beta_tt(3,1,2:end)),'lineWidth',3,'color','black');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% 
% subplot(3,3,8);
% plot(Date,squeeze(beta_tt(3,2,2:end)),'lineWidth',3,'color','black');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% 
% subplot(3,3,9);
% plot(Date,squeeze(beta_tt(3,3,2:end)),'lineWidth',3,'color','black');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% 
% fig = gcf;
% fig.PaperPositionMode = 'auto'
% fig_pos = fig.PaperPosition;
% fig.PaperSize = [fig_pos(3) fig_pos(4)];
% print(fig,'NKPC_ree_init_VAR1_betas','-dpdf');
% 
% figure('Name','Projection Facility','units','normalized','outerposition',[0 0 1 1]);
% subplot(3,1,1);
% plot(Date,pr_flag(2:end),'color','black');
% title('projection facility');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% subplot(3,1,2);
% plot(Date,largest_eig1(2:end),'color','black');
% title('largest eig regime 1');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');
% subplot(3,1,3);
% plot(Date,largest_eig2(2:end),'color','black');
% title('largest eig regime 2');
% xlim([startDate endDate])
% datetick('x','yyyy','keeplimits');




