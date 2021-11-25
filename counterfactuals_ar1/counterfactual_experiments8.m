%run after counterfactual_experiments6.m

%simul_type: 
%1= reproduce the benchmark scenario, both gain and n1 stay at estimated
%values
%2=n1 endogenously determined (estimated case), gain is set by user
%3= n1 set by the user, gain is fixed at the estimated value
%4= both n1 and gain are set by the user


clear;clc;%close all;
% load counterfactual_experimenst6_data.mat;
load counterfactual_experiments7_ver2_data.mat;
rng(1);
simul_LB = [-100 -100 -100 -100 ] ;
simul_UB = [ 100 100 100 100];

%baseline simulations

simul_type=1;
% numSimul=100;
% counter_ = 0;
normal_index3=[];
for jj=normal_index
   disp(jj);


    
seed_ = seed_grid(jj);
n1 = 0.8;
gain=0.001;



[explosive_indicator,SS,PP,shadow_rate, n1,alpha1_tt,beta1_tt,pr_flag,eta_all] =...
    counterfactual_function_rnd3(simul_LB,simul_UB,n1,gain,CF_start,simul_type,CF_length,seed_,iid_indicator);

exp_ind(jj) = explosive_indicator;


% if exp_ind(jj) == 0

%  counter_ = counter_ + 1;
 
P_normal_COV(:,jj) = (PP(1,:) + PP(2,:))';
P_zlb_COV(:,jj)   = (PP(3,:) + PP(4,:))';
pr_flag_COV(:,jj) = pr_flag;
SS_all_COV(:,:,jj) = SS;
n1_COV(:,jj) = n1;
shadow_rate_COV(:,jj) = shadow_rate;
eta_all_COV(:,:,:,jj) = eta_all;

% end

if exp_ind(jj) ==0;
    
    normal_index3 = [normal_index3,jj];
end


end

%=============================================================================

counter_ = length(normal_index3);
LB_index = max(1,round((1-mh_conf)*counter_));
UB_index = max(1,round(mh_conf*counter_));
% LB_index=1;
% UB_index=counter_;

clearvars P_normal_est_sorted P_zlb_est_sorted pr_flag_est_sorted SS_est_sorted n1_sorted eta_all_sorted shadow_rate_sorted;


P_normal_est_sorted = sort(P_normal_COV(:,normal_index3),2);
P_zlb_est_sorted = sort(P_zlb_COV(:,normal_index3),2);
pr_flag_est_sorted = sort(pr_flag_COV(:,normal_index3),2);
SS_est_sorted=sort(SS_all_COV(:,:,normal_index3),3);
n1_sorted = sort(n1_COV(:,normal_index3),2);
eta_all_sorted=sort(eta_all_COV(:,:,:,normal_index3),4);
shadow_rate_sorted=sort(shadow_rate_COV(:,normal_index3),2);



P_normal_est_avg_N_COV = mean(P_normal_est_sorted(:,LB_index:UB_index),2);
P_zlb_est_avg_N_COV  = mean(P_zlb_est_sorted(:,LB_index:UB_index),2);
pr_flag_est_avg_N_COV = mean(pr_flag_est_sorted(:,LB_index:UB_index),2);
SS_est_avg_N_COV  = mean(SS_est_sorted(:,:,LB_index:UB_index),3);
n1_avg_N_COV  = mean(n1_sorted(:,LB_index:UB_index),2);
eta_all_avg_N_COV  = mean(eta_all_sorted(:,:,:,LB_index:UB_index),4);
shadow_rate_avg_N_COV  = mean(shadow_rate_sorted(:,LB_index:UB_index),2);



%=====================================================================================================================

simul_type=3;

% counter_ = 0;
normal_index4=[];
for jj=normal_index
   disp(jj);


    
seed_ = seed_grid(jj);
n1 = 0.9;
gain=0.001;



[explosive_indicator,SS,PP,shadow_rate, n1,alpha1_tt,beta1_tt,pr_flag,eta_all] =...
    counterfactual_function_rnd3(simul_LB,simul_UB,n1,gain,CF_start,simul_type,CF_length,seed_,iid_indicator);

exp_ind(jj) = explosive_indicator;


% if exp_ind(jj) == 0

%  counter_ = counter_ + 1;
 
P_normal_COV(:,jj) = (PP(1,:) + PP(2,:))';
P_zlb_COV(:,jj)   = (PP(3,:) + PP(4,:))';
pr_flag_COV(:,jj) = pr_flag;
SS_all_COV(:,:,jj) = SS;
n1_COV(:,jj) = n1;
shadow_rate_COV(:,jj) = shadow_rate;
eta_all_COV(:,:,:,jj) = eta_all;

% end

if exp_ind(jj) ==0;
    
    normal_index4 = [normal_index4,jj];
end


end

% normal_index4=normal_index3;
%=============================================================================
counter_ = length(normal_index4);
LB_index = max(1,round((1-mh_conf)*counter_));
UB_index = max(1,round(mh_conf*counter_));
% LB_index=1;
% UB_index=counter_;

clearvars P_normal_est_sorted P_zlb_est_sorted pr_flag_est_sorted SS_est_sorted n1_sorted eta_all_sorted shadow_rate_sorted;

P_normal_est_sorted = sort(P_normal_COV(:,normal_index4),2);
P_zlb_est_sorted = sort(P_zlb_COV(:,normal_index4),2);
pr_flag_est_sorted = sort(pr_flag_COV(:,normal_index4),2);
SS_est_sorted=sort(SS_all_COV(:,:,normal_index4),3);
n1_sorted = sort(n1_COV(:,normal_index4),2);
eta_all_sorted=sort(eta_all_COV(:,:,:,normal_index4),4);
shadow_rate_sorted=sort(shadow_rate_COV(:,normal_index4),2);



P_normal_est_avg_N_COV_n90 = mean(P_normal_est_sorted(:,LB_index:UB_index),2);
P_zlb_est_avg_N_COV_n90  = mean(P_zlb_est_sorted(:,LB_index:UB_index),2);
pr_flag_est_avg_N_COV_n90 = mean(pr_flag_est_sorted(:,LB_index:UB_index),2);
SS_est_avg_N_COV_n90  = mean(SS_est_sorted(:,:,LB_index:UB_index),3);
n1_avg_N_COV_n90  = mean(n1_sorted(:,LB_index:UB_index),2);
eta_all_avg_N_COV_n90  = mean(eta_all_sorted(:,:,:,LB_index:UB_index),4);
shadow_rate_avg_N_COV_n90  = mean(shadow_rate_sorted(:,LB_index:UB_index),2);




%=====================================================================================================================

simul_type=3;

% counter_ = 0;
normal_index5=[];
for jj=normal_index
   disp(jj);


    
seed_ = seed_grid(jj);
n1 = 0.5;
gain=0.001;



[explosive_indicator,SS,PP,shadow_rate, n1,alpha1_tt,beta1_tt,pr_flag,eta_all] =...
    counterfactual_function_rnd3(simul_LB,simul_UB,n1,gain,CF_start,simul_type,CF_length,seed_,iid_indicator);

exp_ind(jj) = explosive_indicator;


% if exp_ind(jj) == 0

%  counter_ = counter_ + 1;
 
P_normal_COV(:,jj) = (PP(1,:) + PP(2,:))';
P_zlb_COV(:,jj)   = (PP(3,:) + PP(4,:))';
pr_flag_COV(:,jj) = pr_flag;
SS_all_COV(:,:,jj) = SS;
n1_COV(:,jj) = n1;
shadow_rate_COV(:,jj) = shadow_rate;
eta_all_COV(:,:,:,jj) = eta_all;

% end

if exp_ind(jj) ==0;
    
    normal_index5 = [normal_index5,jj];
end


end


% normal_index5=normal_index3;
%=============================================================================

counter_ = length(normal_index5);
LB_index = max(1,round((1-mh_conf)*counter_));
UB_index = max(1,round(mh_conf*counter_));
% LB_index=1;
% UB_index=counter_;
clearvars P_normal_est_sorted P_zlb_est_sorted pr_flag_est_sorted SS_est_sorted n1_sorted eta_all_sorted shadow_rate_sorted;

P_normal_est_sorted = sort(P_normal_COV(:,normal_index5),2);
P_zlb_est_sorted = sort(P_zlb_COV(:,normal_index5),2);
pr_flag_est_sorted = sort(pr_flag_COV(:,normal_index5),2);
SS_est_sorted=sort(SS_all_COV(:,:,normal_index5),3);
n1_sorted = sort(n1_COV(:,normal_index5),2);
eta_all_sorted=sort(eta_all_COV(:,:,:,normal_index5),4);
shadow_rate_sorted=sort(shadow_rate_COV(:,normal_index5),2);



P_normal_est_avg_N_COV_n10 = mean(P_normal_est_sorted(:,LB_index:UB_index),2);
P_zlb_est_avg_N_COV_n10  = mean(P_zlb_est_sorted(:,LB_index:UB_index),2);
pr_flag_est_avg_N_COV_n10 = mean(pr_flag_est_sorted(:,LB_index:UB_index),2);
SS_est_avg_N_COV_n10  = mean(SS_est_sorted(:,:,LB_index:UB_index),3);
n1_avg_N_COV_n10  = mean(n1_sorted(:,LB_index:UB_index),2);
eta_all_avg_N_COV_n10  = mean(eta_all_sorted(:,:,:,LB_index:UB_index),4);
shadow_rate_avg_N_COV_n10  = mean(shadow_rate_sorted(:,LB_index:UB_index),2);

save counterfactual_simulations8_ver2_data.mat;
load counterfactual_simulations8_ver2_data.mat;
%======================================================================================================================
%=====================BENCHMARK SIMULATIONS--CLASSIFIED AS NORMAL
% 
% figure('Name','Fraction learning---benchmark simulations, normal');
% plot(Date(plot_start:end),n1_avg_N(plot_start:end));
% hold on;
% filled = [n1_UB_N(plot_start:end)',fliplr(n1_LB_N(plot_start:end)')];
% Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
% fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
% xlim([Date(plot_start) Date(end)]);
%   set(gca,'xtick',DateTick)
%   datetick('x','yy','keepticks');  
% 
% 
% 
% 
% figure('Name','Normal regime probability---benchmark simulations, normal');
% plot(Date(plot_start:end),P_normal_est_avg_N(plot_start:end));
% % hold on;
% % filled = [P_normal_est_UB_N(plot_start:end),fliplr(P_normal_est_LB_N(plot_start:end))];
% % Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
% % fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
% xlim([Date(plot_start) Date(end)]);
%   set(gca,'xtick',DateTick)
%   datetick('x','yy','keepticks');  
% 
% 
% 
% figure('Name','Average Output Gap---benchmark simulations, normal');
% plot(Date(plot_start:end),SS_est_avg_N(1,plot_start:end));
% hold on;
% filled = [SS_est_LB_N(1,plot_start:end),fliplr(SS_est_UB_N(1,plot_start:end))];
% Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
% fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
% xlim([Date(plot_start) Date(end)]);
%   set(gca,'xtick',DateTick)
%   datetick('x','yy','keepticks');  
% %   
% figure('Name','Average Inflation---benchmark simulations, normal');
% plot(Date(plot_start:end),pi_bar+SS_est_avg_N(2,plot_start:end));
% hold on;
% filled = [pi_bar+SS_est_LB_N(2,plot_start:end),pi_bar+fliplr(SS_est_UB_N(2,plot_start:end))];
% Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
% fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
% xlim([Date(plot_start) Date(end)]);
%   set(gca,'xtick',DateTick)
%   datetick('x','yy','keepticks');   
% %   
% %   
% % 
% figure('Name','Average Shadow Rate---benchmark simulations, normal');
% plot(Date(plot_start:end),(r_bar1-r_bar2)+shadow_rate_avg_N(plot_start:end));
% hold on;
% filled = [(r_bar1-r_bar2)+shadow_rate_UB_N(plot_start:end)',(r_bar1-r_bar2)+fliplr(shadow_rate_LB_N(plot_start:end)')];
% Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
% fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
% xlim([Date(plot_start) Date(end)]);
%   set(gca,'xtick',DateTick)
%   datetick('x','yy','keepticks');  
% % 
% figure('Name','Average Nominal Interest rate---benchmark simulations, normal');
% plot(Date(plot_start:end),(r_bar1-r_bar2)+SS_est_avg_N(3,plot_start:end));
% hold on;
% filled = [(r_bar1-r_bar2)+SS_est_LB_N(3,plot_start:end),(r_bar1-r_bar2)+fliplr(SS_est_UB_N(3,plot_start:end))];
% Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
% fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
% xlim([Date(plot_start) Date(end)]);
%   set(gca,'xtick',DateTick)
%   datetick('x','yy','keepticks');   



%======================================================================================================================
%=====================SAME SIMULATIONS WITH THE LARGE COVID SHOCKS (2
%STANDARD DEVIATION SUPPLY+DEMAND SHOCKS----SIMULATIONS WITH NORMAL INDEX

figure('Name','Fraction learning---simulations with shock, normal');
plot(Date(plot_start:end),n1_avg_N_COV(plot_start:end),'-','color','black','lineWidth',2);
hold on;
plot(Date(plot_start:end),n1_avg_N_COV_n90(plot_start:end),'-.','color','blue','lineWidth',2);
hold on;
plot(Date(plot_start:end),n1_avg_N_COV_n10(plot_start:end),'--','color','green','lineWidth',2);
hold on;
regimes_box(n1_avg_N_COV(plot_start:end),CF_period,Date); 

xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');  
  
  set(gca,'FontSize',14);
  xlabel('Date','FontSize',14);
  ylabel('n_t^L','FontSize',14);
%legend('Estimated fractions','90% de-anchored','50% de-anchored');
generate_figures('ar1_CF5_covidShockFr_n1','figures'); 


figure('Name','Normal regime probability---simulations with shock, normal');
plot(Date(plot_start:end),P_normal_est_avg_N_COV(plot_start:end),'-','color','black','lineWidth',2);
hold on;
plot(Date(plot_start:end),P_normal_est_avg_N_COV_n90(plot_start:end),'-.','color','blue','lineWidth',2);
hold on;
plot(Date(plot_start:end),P_normal_est_avg_N_COV_n10(plot_start:end),'--','color','green','lineWidth',2);
hold on;
regimes_box(P_normal_est_avg_N_COV(plot_start:end),CF_period,Date); 

xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');  
  
    set(gca,'FontSize',14);
  xlabel('Date','FontSize',14);
  ylabel('Taylor Rule Probability','FontSize',14);
%legend('Estimated fractions','90% de-anchored','50% de-anchored');
generate_figures('ar1_CF5_covidShockFr_regimeProb','figures'); 


figure('Name','Average Output Gap---simulations with shock, normal');
plot(Date(plot_start:end),SS_est_avg_N_COV(1,plot_start:end),'-','color','black','lineWidth',2);
hold on;
plot(Date(plot_start:end),SS_est_avg_N_COV_n90(1,plot_start:end),'-.','color','blue','lineWidth',2);
hold on;
plot(Date(plot_start:end),SS_est_avg_N_COV_n10(1,plot_start:end),'--','color','green','lineWidth',2);
hold on;
regimes_box(SS_est_avg_N_COV(1,plot_start:end),CF_period,Date); 


xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');  
    set(gca,'FontSize',14);
  xlabel('Date','FontSize',14);
  ylabel('Output Gap','FontSize',14);
%legend('Estimated fractions','90% de-anchored','50% de-anchored');
generate_figures('ar1_CF5_covidShockFr_gap','figures'); 
%   
figure('Name','Average Inflation---simulations with shock, normal');
plot(Date(plot_start:end),pi_bar+SS_est_avg_N_COV(2,plot_start:end),'-','color','black','lineWidth',2);
hold on;
plot(Date(plot_start:end),pi_bar+SS_est_avg_N_COV_n90(2,plot_start:end),'-.','color','blue','lineWidth',2);
hold on;
plot(Date(plot_start:end),pi_bar+SS_est_avg_N_COV_n10(2,plot_start:end),'--','color','green','lineWidth',2);
hold on;
regimes_box(pi_bar+SS_est_avg_N_COV(2,plot_start:end),CF_period,Date); 

xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks'); 
    set(gca,'FontSize',14);
  xlabel('Date','FontSize',14);
  ylabel('Inflation','FontSize',14);
%legend('Estimated fractions','90% de-anchored','50% de-anchored');
generate_figures('ar1_CF5_covidShockFr_pi','figures'); 
%   
%   
% 
figure('Name','Average Shadow Rate---simulations with shock, normal');
plot(Date(plot_start:end),(r_bar1-r_bar2)+shadow_rate_avg_N_COV(plot_start:end),'-','color','black','lineWidth',2);
hold on;
plot(Date(plot_start:end),(r_bar1-r_bar2)+shadow_rate_avg_N_COV_n90(plot_start:end),'-.','color','blue','lineWidth',2);
hold on;
plot(Date(plot_start:end),(r_bar1-r_bar2)+shadow_rate_avg_N_COV_n10(plot_start:end),'--','color','green','lineWidth',2);
hold on;
regimes_box((r_bar1-r_bar2)+shadow_rate_avg_N_COV_n10(plot_start:end),CF_period,Date);

xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');
    set(gca,'FontSize',14);
  xlabel('Date','FontSize',14);
  ylabel('Shadow Rate','FontSize',14);
%legend('Estimated fractions','90% de-anchored','50% de-anchored');
  generate_figures('ar1_CF5_covidShockFr_SR','figures'); 

% 
figure('Name','Average Nominal Interest rate---simulations with shock, normal');
plot(Date(plot_start:end),(r_bar1-r_bar2)+SS_est_avg_N_COV(3,plot_start:end),'-','color','black','lineWidth',2);
hold on;
plot(Date(plot_start:end),(r_bar1-r_bar2)+SS_est_avg_N_COV_n90(3,plot_start:end),'-.','color','blue','lineWidth',2);
hold on;
plot(Date(plot_start:end),(r_bar1-r_bar2)+SS_est_avg_N_COV_n10(3,plot_start:end),'--','color','green','lineWidth',2);
hold on;
regimes_box((r_bar1-r_bar2)+SS_est_avg_N_COV_n10(3,plot_start:end),CF_period,Date);

xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');   
    set(gca,'FontSize',14);
  xlabel('Date','FontSize',14);
  ylabel('Nominal Interest Rate','FontSize',14);
%legend('Estimated fractions','90% de-anchored','50% de-anchored');
generate_figures('ar1_CF5_covidShockFr_intRate','figures'); 


  
  
  
 figure('Name','AR(1) Shock Process, Output Gap');
 plot(Date(plot_start:end),SS_est_avg_N_COV(4,plot_start:end),'-','color','black','lineWidth',2);
 hold on;
plot(Date(plot_start:end),SS_est_avg_N(4,plot_start:end),'--','color','red','lineWidth',2);
hold on;
regimes_box(SS_est_avg_N_COV(4,plot_start:end),CF_period,Date);

xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');   
    set(gca,'FontSize',14);
  xlabel('Date','FontSize',14);
  ylabel('Demand Shock','FontSize',14);
  leg=legend('covid shock','benchmark');
  leg.FontSize=14;
  leg.Location='southwest';
  generate_figures('ar1_CF5_covidShockFr_ar1_gap','figures'); 


figure('Name','AR(1) Shock Process, Inflation---simulations with shock, normal');
plot(Date(plot_start:end),SS_est_avg_N_COV(5,plot_start:end),'-','color','black','lineWidth',2);
hold on;
plot(Date(plot_start:end),SS_est_avg_N(5,plot_start:end),'--','color','red','lineWidth',2);
hold on;
regimes_box(SS_est_avg_N_COV(5,plot_start:end),CF_period,Date);

xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');   
  %legend('covid shock','benchmark');
    set(gca,'FontSize',14);
  xlabel('Date','FontSize',14);
  ylabel('Cost-push Shock','FontSize',14);
  generate_figures('ar1_CF5_covidShockFr_ar1_pi','figures'); 

  
  
 disp('Taylor rule probabilities, starting from 2020Q1');
 table([P_normal_est_avg_N_COV(CF_start:end) P_normal_est_avg_N_COV_n10(CF_start:end) P_normal_est_avg_N_COV_n90(CF_start:end)]) 
  

