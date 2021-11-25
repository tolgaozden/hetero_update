clear;clc;close all;
tic
warning('off','all');
% seed=round(rand*100000)
seed=1;
rng(seed);
load MCMC_results_var1_4regime_july3.mat;
cutoff_ =  100000; 
%  model.decreasing_gain=0;
% mode=x;
% Sigma=diag(diag(H));
% Sigma=H;


para_names = {'pi_bar(1)','r_bar(2)','kappa(3)','tau(4)',...
    'phi_pi(5)','phi_y(6)','phi_dy(7)','rho_y(8)','rho_pi(9)','rho_r(10)',...
    'eta_y(11)','eta_pi(12)','eta_r(13)','iota_y(14)','iota_p(15)',...
    'r_bar_zlb(16)','eta_r_zlb(17)','1-p_11(18)','1-p_22(19)','gain_y(20)','memory(21)','intensity(22)'};



param_lb=[0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]';
param_ub=[1e5 1e5 1 1e5 1e5 1e5 1e5 1 1 1 1e5 1e5 1e5 1 1 1e5 1e5 1 1 1e5 1 1e5]';

param_bounds = [param_lb,param_ub];

% load param_init.mat;mode=param_init;
% load init_H.mat; Sigma=H;model.N_fixedPoint=100;
% model.hetero_gains=0;
%============================
% Ndraws=250000;
% numVar=length(mode);
% c=0.2; %
% c_eps=0.2;
% recursiveAverages=nan(Ndraws,numVar);
% acc_lb=0.2;
% acc_ub=0.4;
% Nburn=round(Ndraws/2);
% Nburn=1;
% posteriorDraws=nan(Ndraws,numVar);
% currentDraw=mvnrnd(mode,c*Sigma);
% posteriorDraws(1,:)=currentDraw;
% accept=0;
% objective=-likelihood(posteriorDraws(1,:),param_bounds);
% counter=0;
% logposterior=nan*ones(Ndraws,1);
accept=0;
for i=cutoff_:Ndraws
    
    currentDraw=mvnrnd(posteriorDraws(i,:),c*Sigma);
    objectiveNew=-likelihood(currentDraw,param_bounds);
    alpha=min(1,exp(objectiveNew-objective));
    u=rand(1);

    if u<=alpha
        posteriorDraws(i+1,:)=currentDraw;
        accept=accept+1;
        objective=objectiveNew;
        logposterior(i+1)=objectiveNew;
    else
        posteriorDraws(i+1,:)=posteriorDraws(i,:);
        logposterior(i+1)=objective;
    end

% acceptanceRate=accept/i;
acceptanceRate = accept/(i+1-cutoff_);

% if acceptanceRate<acc_lb
%     c=(1-c_eps)*c;
% elseif acceptanceRate>acc_ub
%         c=(1+c_eps)*c;
%  end

counter=counter+1;
if counter==1
    toc
     disp(['Acceptance Rate: ', num2str(acceptanceRate)]);
    disp(['Remaining Draws: ', num2str(Ndraws-i)]);
     disp(['Scale Coefficient: ', num2str(c)]);
    counter=0;
end


end

% save MCMC_results_july6th;
save MCMC_results_july6th_4regime_resumed;



figure('Name','beta-level-sac','units','normalized','outerposition',[0 0 1 0.35]);
for i=1:numVar;
subplot(8,6,i);hist(posteriorDraws(Nburn:end,i));hold on;plot([mode(i) mode(i)],[ylim],'r'); 
end




figure;
title('Recursive Averages');

     disp('calculating recursive averages for cusum plots...');
%      disp(i);

recursiveAverages=zeros(Ndraws,numVar);
recursiveAverages(1,:) = posteriorDraws(1,:);
for j=2:Ndraws
    recursiveAverages(j,:) = (recursiveAverages(j-1,:)*(j-1) + posteriorDraws(j,:)) / j;
    
    
    
end

rollingAverages=zeros(Ndraws,numVar);
rollingAverages(1,:) = posteriorDraws(1,:);
for j=2:Ndraws
    
 
    rollingAverages(j,:) = 0.99*(rollingAverages(j-1,:) + 0.01*posteriorDraws(j,:));
 
        
    
    
end

% for j=1:Ndraws
%     disp(j)
%     recursiveAverages(j,:)=mean(posteriorDraws(1:j,:));
%     
% end

 for i=1:numVar;
   subplot(5,5,i);
   plot(recursiveAverages(5:end,i),'lineWidth',2);
  
 end
 
  for i=1:numVar;
   subplot(5,5,i);
   plot(rollingAverages(5:end,i),'lineWidth',2);
  
 end
 

 disp('POSTERIOR MEAN')
  mh_conf_sig=0.95;
 posteriorMean=mean(posteriorDraws(Nburn+1:end,:))
posteriorDist=posteriorDraws(Nburn+1:end,:);
posteriorDist=sort(posteriorDist);
hpdDraws=round((1-mh_conf_sig)*length(posteriorDist));
kk=zeros(hpdDraws,13);


for paraInd=1:length(mode)
    jj=size(posteriorDist,1)-hpdDraws-2;

for ii=1:hpdDraws
    kk(ii,paraInd)=posteriorDist(jj,paraInd)-posteriorDist(ii,paraInd);
    jj=jj+1;
end
[kmin,idx]=min(kk(:,paraInd));
hpd_interval(paraInd,:)=[posteriorDist(idx,paraInd) posteriorDist(idx,paraInd)+kmin];
post_deciles(paraInd,:)=posteriorDist([round(0.05*length(posteriorDist(:,paraInd)))...
    round(0.2*length(posteriorDist(:,paraInd)))...
    round(0.3*length(posteriorDist(:,paraInd)))...
    round(0.4*length(posteriorDist(:,paraInd)))...
    round(0.5*length(posteriorDist(:,paraInd)))...
    round(0.6*length(posteriorDist(:,paraInd)))...
    round(0.7*length(posteriorDist(:,paraInd)))...
    round(0.8*length(posteriorDist(:,paraInd)))...
    round(0.95*length(posteriorDist(:,paraInd)))],paraInd);
end
 
 %=========================================================================\
%modified harmonic mean estimator
%posteriorDraws-->likl values


