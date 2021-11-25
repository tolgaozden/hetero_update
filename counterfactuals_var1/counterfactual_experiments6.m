clear;clc;%close all;
load counterfactual_initials;
rng(1);

para_names = {'pi_bar(1)','r_bar(2)','kappa(3)','tau(4)',...
    'phi_pi(5)','phi_y(6)','phi_dy(7)','rho_y(8)','rho_pi(9)','rho_r(10)',...
    'eta_y(11)','eta_pi(12)','eta_r(13)','iota_y(14)','iota_p(15)',...
    'r_bar_zlb(16)','eta_r_zlb(17)','1-p_11(18)','1-p_22(19)','gain_y(20)','memory(21)','intensity(22)'};

% load estimation_results_march15.mat;
pi_bar = parameters(1);
r_bar1 = parameters(2);
r_bar2 =parameters(16);
%simul_type: 
%1= reproduce the benchmark scenario, both gain and n1 stay at estimated
%values
%2=n1 endogenously determined (estimated case), gain is set by user
%3= n1 set by the user, gain is fixed at the estimated value
%4= both n1 and gain are set by the user

simul_LB = [-100 -100 -100 -100 ] ;
simul_UB = [ 100 100 100 100];

n1 = 0;
gain = parameters(20);
CF_start=152;
plot_start = CF_start - 60;
CF_length=20;
numSimul=1000;
mh_conf = 0.9;

simul_type=1;
iid_indicator=0;
T = length(S_filtered);
CF_period = [CF_start, CF_length+CF_start-1];

% startDate=datenum('01-06-1982');
% endDate = datenum('01-12-2024');
%IMPORTANT: ACTUAL DATES ARE 1-06-1982 and 01-12-2014 respectively.
%the figures marks the year by end-of-the-year-quarter whereas I would like to
%mark them by beginning-of-the-year-quarterly, so I shift the axis forward
%by 1 year.
startDate=datenum('01-04-1983');
endDate = datenum('01-10-2025');

Date=linspace(startDate,endDate,T+CF_length);
% Date  = Date(CF_start:end);
DateTick = linspace(Date(plot_start),Date(end),floor(T/20));

% 
% 
% [explosive_indicator_benchmark,SS_benchmark,PP_benchmark,shadow_rate_benchmark,n1_benchmark,alpha1_tt_benchmark,beta1_tt_benchmark,prFlag_benchmark] =...
%     counterfactual_function(simul_LB,simul_UB,n1,gain,CF_start,simul_type);
% 
% %descriptive statistics benchmark case
% mean_benchmark= [mean(SS_benchmark(:,CF_start:end)')' ;
%     mean(shadow_rate_benchmark(CF_start:end))];
% 
% 
% P_normal_benchmark = PP_benchmark(1,:) + PP_benchmark(2,:);
% P_zlb_benchmark    = PP_benchmark(3,:) + PP_benchmark(4,:);

%==============================benchmark scenario with fixed n1 (endogenous determined)============================================

 seed_grid = round(5000*rand(numSimul,1))
counter_ = 0;

deflationary_index=[];
normal_index=[];

for jj=1:numSimul
      disp(jj)
seed_ = seed_grid(jj);
% gain = parameters(20);
gain = 0.01;
n1 = 0.1;
T = length(S_filtered);




[explosive_indicator,SS,PP,shadow_rate, n1,alpha1_tt,beta1_tt,pr_flag,eta_all] =...
    counterfactual_function_rnd2(simul_LB,simul_UB,n1,gain,CF_start,simul_type,CF_length,seed_,iid_indicator);

exp_ind(jj) = explosive_indicator;

if explosive_indicator ==0
    counter_ = counter_ + 1;
    
P_normal_est(:,counter_) = (PP(1,:) + PP(2,:))';
P_zlb_est(:,counter_)   = (PP(3,:) + PP(4,:))';
pr_flag_est(:,counter_) = pr_flag;
SS_all_est(:,:,counter_) = SS;
n1_est(:,counter_) = n1;
shadow_rate_est(:,counter_) = shadow_rate;
eta_all_est(:,:,:,counter_) = eta_all;
end


% if explosive_indicator ==0
%     if mean(shadow_rate_est(CF_start:end,counter_)) > -(r_bar1-r_bar2)
%         normal_index =[normal_index,counter_];
%     else
%         deflationary_index=[deflationary_index,counter_];
%     end
% end

if explosive_indicator ==0
    if mean(PP(1,CF_start:end) + PP(2,CF_start:end)) <=0.5
    deflationary_index=[deflationary_index,counter_];
    
    elseif mean(PP(1,CF_start:end) + PP(2,CF_start:end)) >0.5   
 normal_index =[normal_index,counter_];
    end
 end

end

disp('Non-explosive Simulations Fraction in %');
disp(100*counter_/numSimul);

disp('Fraction of explosive/deflationary/discarded simulations:');
disp(length(deflationary_index)/counter_);

disp('Fraction of simulations that are kept:');
disp(length(normal_index)/counter_);



%================================================================
%===============overall moments==================================
LB_index = max(1,round((1-mh_conf)*counter_));
UB_index = max(1,round(mh_conf*counter_));

P_normal_est_sorted = sort(P_normal_est,2);
P_zlb_est_sorted = sort(P_zlb_est,2);
pr_flag_est_sorted = sort(pr_flag_est,2);
SS_est_sorted=sort(SS_all_est,3);
n1_sorted = sort(n1_est,2);
eta_all_sorted=sort(eta_all_est,4);
shadow_rate_sorted=sort(shadow_rate_est,2);


P_normal_est_avg = mean(P_normal_est_sorted(:,LB_index:UB_index),2);
P_zlb_est_avg = mean(P_zlb_est_sorted(:,LB_index:UB_index),2);
pr_flag_est_avg= mean(pr_flag_est_sorted(:,LB_index:UB_index),2);
SS_est_avg = mean(SS_est_sorted(:,:,LB_index:UB_index),3);
n1_avg = mean(n1_sorted(:,LB_index:UB_index),2);
eta_all_avg = mean(eta_all_sorted(:,:,:,LB_index:UB_index),4);
shadow_rate_avg = mean(shadow_rate_sorted(:,LB_index:UB_index),2);



%sorted matrices


%lb
P_normal_est_LB = P_normal_est_sorted(:,LB_index);
P_zlb_est_LB = P_zlb_est_sorted(:,LB_index);
pr_flag_est_LB = pr_flag_est_sorted(:,LB_index);
SS_est_LB = SS_est_sorted(:,:,LB_index);
n1_LB = n1_sorted(:,LB_index);
eta_all_LB = eta_all_sorted(:,:,:,LB_index);
shadow_rate_LB = shadow_rate_sorted(:,LB_index);



%ub
P_normal_est_UB = P_normal_est_sorted(:,UB_index);
P_zlb_est_UB = P_zlb_est_sorted(:,UB_index);
pr_flag_est_UB = pr_flag_est_sorted(:,UB_index);
SS_est_UB = SS_est_sorted(:,:,UB_index);
n1_UB = n1_sorted(:,UB_index);
eta_all_UB = eta_all_sorted(:,:,:,UB_index);
shadow_rate_UB = shadow_rate_sorted(:,UB_index);

%===============moments from deflationary simulations==================================
counter_ = length(deflationary_index);
LB_index = max(1,round((1-mh_conf)*counter_));
UB_index = max(1,round(mh_conf*counter_));

P_normal_est_sorted = sort(P_normal_est(:,deflationary_index),2);
P_zlb_est_sorted = sort(P_zlb_est(:,deflationary_index),2);
pr_flag_est_sorted = sort(pr_flag_est(:,deflationary_index),2);
SS_est_sorted=sort(SS_all_est(:,:,deflationary_index),3);
n1_sorted = sort(n1_est(:,deflationary_index),2);
eta_all_sorted=sort(eta_all_est(:,:,:,deflationary_index),4);
shadow_rate_sorted=sort(shadow_rate_est(:,deflationary_index),2);

P_normal_est_avg_D = mean(P_normal_est_sorted(:,LB_index:UB_index),2);
P_zlb_est_avg_D = mean(P_zlb_est_sorted(:,LB_index:UB_index),2);
pr_flag_est_avg_D= mean(pr_flag_est_sorted(:,LB_index:UB_index),2);
SS_est_avg_D = mean(SS_est_sorted(:,:,LB_index:UB_index),3);
n1_avg_D = mean(n1_sorted(:,LB_index:UB_index),2);
eta_all_avg_D = mean(eta_all_sorted(:,:,:,LB_index:UB_index),4);
shadow_rate_avg_D = mean(shadow_rate_sorted(:,LB_index:UB_index),2);


%sorted matrices


%lb
P_normal_est_LB_D = P_normal_est_sorted(:,LB_index);
P_zlb_est_LB_D = P_zlb_est_sorted(:,LB_index);
pr_flag_est_LB_D = pr_flag_est_sorted(:,LB_index);
SS_est_LB_D = SS_est_sorted(:,:,LB_index);
n1_LB_D = n1_sorted(:,LB_index);
eta_all_LB_D = eta_all_sorted(:,:,:,LB_index);
shadow_rate_LB_D = shadow_rate_sorted(:,LB_index);



%ub
P_normal_est_UB_D = P_normal_est_sorted(:,UB_index);
P_zlb_est_UB_D = P_zlb_est_sorted(:,UB_index);
pr_flag_est_UB_D = pr_flag_est_sorted(:,UB_index);
SS_est_UB_D = SS_est_sorted(:,:,UB_index);
n1_UB_D = n1_sorted(:,UB_index);
eta_all_UB_D = eta_all_sorted(:,:,:,UB_index);
shadow_rate_UB_D = shadow_rate_sorted(:,UB_index);

%===============moments from normal simulations==================================
counter_ = length(normal_index);
LB_index = max(1,round((1-mh_conf)*counter_));
UB_index = max(1,round(mh_conf*counter_));

P_normal_est_sorted = sort(P_normal_est(:,normal_index),2);
P_zlb_est_sorted = sort(P_zlb_est(:,normal_index),2);
pr_flag_est_sorted = sort(pr_flag_est(:,normal_index),2);
SS_est_sorted=sort(SS_all_est(:,:,normal_index),3);
n1_sorted = sort(n1_est(:,normal_index),2);
eta_all_sorted=sort(eta_all_est(:,:,:,normal_index),4);
shadow_rate_sorted=sort(shadow_rate_est(:,normal_index),2);

P_normal_est_avg_N = mean(P_normal_est_sorted(:,LB_index:UB_index),2);
P_zlb_est_avg_N = mean(P_zlb_est_sorted(:,LB_index:UB_index),2);
pr_flag_est_avg_N= mean(pr_flag_est_sorted(:,LB_index:UB_index),2);
SS_est_avg_N = mean(SS_est_sorted(:,:,LB_index:UB_index),3);
n1_avg_N = mean(n1_sorted(:,LB_index:UB_index),2);
eta_all_avg_N = mean(eta_all_sorted(:,:,:,LB_index:UB_index),4);
shadow_rate_avg_N = mean(shadow_rate_sorted(:,LB_index:UB_index),2);


%sorted matrices


%lb
P_normal_est_LB_N = P_normal_est_sorted(:,LB_index);
P_zlb_est_LB_N = P_zlb_est_sorted(:,LB_index);
pr_flag_est_LB_N = pr_flag_est_sorted(:,LB_index);
SS_est_LB_N = SS_est_sorted(:,:,LB_index);
n1_LB_N = n1_sorted(:,LB_index);
eta_all_LB_N = eta_all_sorted(:,:,:,LB_index);
shadow_rate_LB_N = shadow_rate_sorted(:,LB_index);



%ub
P_normal_est_UB_N = P_normal_est_sorted(:,UB_index);
P_zlb_est_UB_N = P_zlb_est_sorted(:,UB_index);
pr_flag_est_UB_N = pr_flag_est_sorted(:,UB_index);
SS_est_UB_N = SS_est_sorted(:,:,UB_index);
n1_UB_N = n1_sorted(:,UB_index);
eta_all_UB_N = eta_all_sorted(:,:,:,UB_index);
shadow_rate_UB_N = shadow_rate_sorted(:,UB_index);

%========================================================
% 
save counterfactual_experimenst6_data.mat;
load counterfactual_experimenst6_data.mat;



figure('Name','Fraction learning');
filled = [n1_UB(plot_start:end)',fliplr(n1_LB(plot_start:end)')];
Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
hold on;
plot(Date(plot_start:end),n1_avg(plot_start:end),'--','color','black','lineWidth',2);
xlim([Date(plot_start) Date(end)]);
ylim([0 1]);
hold on;
regimes_box(n1_avg(plot_start:end),CF_period,Date); 

  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');  
  xlabel('Date');
  ylabel('n_t^L');
  
  set(gca,'FontSize',14);
generate_figures('var1_CF3_randomShocks1_overall_n1','figures'); 



figure('Name','Normal regime probability');
plot(Date(plot_start:end),P_normal_est_avg(plot_start:end),'--','color','black','lineWidth',2);
hold on;
regimes_box(P_normal_est_avg(plot_start:end),CF_period,Date); 
% hold on;
% filled = [P_normal_est_UB(plot_start:end),fliplr(P_normal_est_LB(plot_start:end))];
% Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
% fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
xlim([Date(plot_start) Date(end)]);
ylim([0 1]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');  
   xlabel('Date');
  ylabel('Probability of Taylor Regime');
  set(gca,'FontSize',14);
generate_figures('var1_CF3_randomShocks1_overall_regimeProb','figures'); 


figure('Name','Average Output Gap');
filled = [SS_est_LB(1,plot_start:end),fliplr(SS_est_UB(1,plot_start:end))];
Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
hold on;
plot(Date(plot_start:end),SS_est_avg(1,plot_start:end),'--','color','black','lineWidth',2);
hold on;
regimes_box(SS_est_avg(1,plot_start:end),CF_period,Date); 
xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');  
     xlabel('Date','FontSize',14);
  ylabel('Output Gap','FontSize',14);
  set(gca,'FontSize',14);
  generate_figures('var1_CF3_randomShocks1_overall_gap','figures'); 
%   
figure('Name','Average Inflation');
filled = [pi_bar+SS_est_LB(2,plot_start:end),pi_bar+fliplr(SS_est_UB(2,plot_start:end))];
Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
hold on;
plot(Date(plot_start:end),pi_bar+SS_est_avg(2,plot_start:end),'--','color','black','lineWidth',2);
hold on;
regimes_box(SS_est_avg(2,plot_start:end),CF_period,Date); 

xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');   
     xlabel('Date','FontSize',14);
  ylabel('Inflation ','FontSize',14);
  set(gca,'FontSize',14);
  generate_figures('var1_CF3_randomShocks1_overall_pi','figures'); 
%   
%   
% 
figure('Name','Average Shadow Rate');
filled = [(r_bar1-r_bar2)+shadow_rate_UB(plot_start:end)',(r_bar1-r_bar2)+fliplr(shadow_rate_LB(plot_start:end)')];
Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
hold on;
plot(Date(plot_start:end),(r_bar1-r_bar2)+shadow_rate_avg(plot_start:end),'--','color','black','lineWidth',2);
hold on;
regimes_box(shadow_rate_avg(plot_start:end),CF_period,Date); 
xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');  
     xlabel('Date','FontSize',14);
  ylabel('Shadow Rate','FontSize',14);
  set(gca,'FontSize',14);
  generate_figures('var1_CF3_randomShocks1_overall_SR','figures'); 
% 
figure('Name','Average Nominal Interest rate');
filled = [(r_bar1-r_bar2)+SS_est_LB(3,plot_start:end),(r_bar1-r_bar2)+fliplr(SS_est_UB(3,plot_start:end))];
Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
hold on;
plot(Date(plot_start:end),(r_bar1-r_bar2)+SS_est_avg(3,plot_start:end),'--','color','black','lineWidth',2);
hold on;
regimes_box((r_bar1-r_bar2)+SS_est_avg(3,plot_start:end),CF_period,Date); 
   xlabel('Date','FontSize',14);
  ylabel('Nominal Interest Rate','FontSize',14);
xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');   
  set(gca,'FontSize',14);
  generate_figures('var1_CF3_randomShocks1_overall_intRate','figures'); 
 
% 
% 
% 
% 
% figure('Name','AR(1) Shock Process, Output Gap');
% plot(Date(plot_start:end),SS_est_avg(4,plot_start:end));
% hold on;
% filled = [SS_est_LB(4,plot_start:end),fliplr(SS_est_UB(4,plot_start:end))];
% Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
% fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
% xlim([Date(plot_start) Date(end)]);
%   set(gca,'xtick',DateTick)
%   datetick('x','yy','keepticks');   
  
% 
% 
% figure('Name','AR(1) Shock Process, Inflation');
% plot(Date(plot_start:end),SS_est_avg(5,plot_start:end));
% hold on;
% filled = [SS_est_LB(5,plot_start:end),fliplr(SS_est_UB(5,plot_start:end))];
% Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
% fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
% xlim([Date(plot_start) Date(end)]);
%   set(gca,'xtick',DateTick)
%   datetick('x','yy','keepticks');   
%   
%   
% figure('Name','iid shock, output gap');
% plot(Date(plot_start:end),eta_all_avg(plot_start:end,1,1));
% xlim([Date(plot_start) Date(end)]);
%   set(gca,'xtick',DateTick)
%   datetick('x','yy','keepticks'); 
%   
% figure('Name','iid shock, inflation');
% plot(Date(plot_start:end),eta_all_avg(plot_start:end,2,1));
% xlim([Date(plot_start) Date(end)]);
%   set(gca,'xtick',DateTick)
%   datetick('x','yy','keepticks');   



figure('Name','Explosive Indicator Across Simulations');
plot(exp_ind,'--','color','black','lineWidth',2);



%==========================================
%Normal regime averages
disp('Probability of no ZLB in the next year:');
col(1,1)=mean(P_normal_est_avg(CF_start:CF_start+4-1));
disp(col(1,1));

disp('Probability of no ZLB in the next two years:');
col(2,1)=mean(P_normal_est_avg(CF_start:CF_start+8-1));
disp(col(2,1));

disp('Probability of no ZLB in the next five years:');
col(3,1)=mean(P_normal_est_avg(CF_start:CF_start+20-1));
disp(col(3,1));

%Output gap averages
disp('Output Gap average over the next year');
col(1,2)=mean(SS_est_avg(1,CF_start+4-1));
disp(col(1,2));

disp('Output Gap average over the next two years');
col(2,2)=mean(SS_est_avg(1,CF_start+8-1));
disp(col(2,2));

disp('Output Gap average over the next five years');
col(3,2)=mean(SS_est_avg(1,CF_start+20-1));
disp(col(3,2));

%Inflation averages
disp('Inflation average over the next year');
col(1,3)=mean(SS_est_avg(2,CF_start+4-1));
disp(col(1,3));

disp('Inflation averega over the next two years');
col(2,3)=mean(SS_est_avg(2,CF_start+8-1));
disp(col(2,3));

disp('Inflation average over the next five years');
col(3,3)=mean(SS_est_avg(2,CF_start+20-1));
disp(col(3,3));

%shadow rate averages
disp('Inflation average over the next year');
col(1,4)=mean(shadow_rate_avg(CF_start+4-1));
disp(col(1,4));

disp('Inflation averega over the next two years');
col(2,4)=mean(shadow_rate_avg(CF_start+8-1));
disp(col(2,4));

disp('Inflation average over the next five years');
col(3,4)=mean(shadow_rate_avg(CF_start+20-1));
disp(col(3,4));


disp('Shock averages over all simulations');
disp(mean(eta_all_avg(CF_start:end,1:2,1)));
   
disp('Shock averages over discarded simulations');
disp(mean(eta_all_avg_D(CF_start:end,1:2,1)));

disp('Shock averages over retained simulations');
disp(mean(eta_all_avg_N(CF_start:end,1:2,1)));

%======================================================================================================================
%=====================FIGURES FOR SIMULATIONS CLASSIFIED AS DEFLATIONARY

figure('Name','Fraction learning');

filled = [n1_UB_D(plot_start:end)',fliplr(n1_LB_D(plot_start:end)')];
Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
hold on;
plot(Date(plot_start:end),n1_avg_D(plot_start:end),'--','color','black','lineWidth',2);
ylim([0 1]);
hold on;
regimes_box(n1_avg_D(plot_start:end),CF_period,Date); 

xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');  
  set(gca,'FontSize',14);
     xlabel('Date','FontSize',14);
  ylabel('n_t^L','FontSize',14);
 generate_figures('var1_CF3_randomShocks1_zlbReg_n1','figures'); 
  



figure('Name','Normal regime probability');
plot(Date(plot_start:end),P_normal_est_avg_D(plot_start:end),'--','color','black','lineWidth',2);
ylim([0 1]);
hold on;
regimes_box(P_normal_est_avg_D(plot_start:end),CF_period,Date); 
% hold on;
% filled = [P_normal_est_UB_D(plot_start:end),fliplr(P_normal_est_LB_D(plot_start:end))];
% Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
% fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks'); 
  set(gca,'FontSize',14);
     xlabel('Date','FontSize',14);
  ylabel('Taylor Rule Probability','FontSize',14);
 generate_figures('var1_CF3_randomShocks1_zlbReg_regimeProb','figures'); 


figure('Name','Average Output Gap');

filled = [SS_est_LB_D(1,plot_start:end),fliplr(SS_est_UB_D(1,plot_start:end))];
Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
hold on;

plot(Date(plot_start:end),SS_est_avg_D(1,plot_start:end),'--','color','black','lineWidth',2);
ylim([-35 15]);
hold on;
regimes_box(SS_est_avg_D(1,plot_start:end),CF_period,Date); 
xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');  
       xlabel('Date','FontSize',14);
  ylabel('Output Gap','FontSize',14);
  set(gca,'FontSize',14);
  
   generate_figures('var1_CF3_randomShocks1_zlbReg_gap','figures'); 
%   
figure('Name','Average Inflation');

filled = [pi_bar+SS_est_LB_D(2,plot_start:end),pi_bar+fliplr(SS_est_UB_D(2,plot_start:end))];
Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
hold on;
plot(Date(plot_start:end),pi_bar+SS_est_avg_D(2,plot_start:end),'--','color','black','lineWidth',2);
ylim([-3 4]);
hold on;
regimes_box(SS_est_avg_D(2,plot_start:end),CF_period,Date); 
xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');  
         xlabel('Date','FontSize',14);
  ylabel('Inflation','FontSize',14);
  set(gca,'FontSize',14);
   generate_figures('var1_CF3_randomShocks1_zlbReg_pi','figures'); 
%   
%   
% 
figure('Name','Average Shadow Rate');
filled = [(r_bar1-r_bar2)+shadow_rate_UB_D(plot_start:end)',(r_bar1-r_bar2)+fliplr(shadow_rate_LB_D(plot_start:end)')];
Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
hold on;
plot(Date(plot_start:end),(r_bar1-r_bar2)+shadow_rate_avg_D(plot_start:end),'--','color','black','lineWidth',2);
ylim([-2.5 5]);
hold on;
regimes_box((r_bar1-r_bar2)+shadow_rate_avg_D(plot_start:end),CF_period,Date); 

xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');  
         xlabel('Date','FontSize',14);
  ylabel('Shadow Rate','FontSize',14);
  set(gca,'FontSize',14);
   generate_figures('var1_CF3_randomShocks1_zlbReg_SR','figures'); 
% 
figure('Name','Average Nominal Interest rate');
filled = [(r_bar1-r_bar2)+SS_est_LB_D(3,plot_start:end),(r_bar1-r_bar2)+fliplr(SS_est_UB_D(3,plot_start:end))];
Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
hold on;
plot(Date(plot_start:end),(r_bar1-r_bar2)+SS_est_avg_D(3,plot_start:end),'--','color','black','lineWidth',2);
ylim([-0.5 5]);
hold on;
regimes_box((r_bar1-r_bar2)+SS_est_avg_D(3,plot_start:end),CF_period,Date); 

xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');  
         xlabel('Date','FontSize',14);
  ylabel('Nominal Interest Rate','FontSize',14);
  set(gca,'FontSize',14);
   generate_figures('var1_CF3_randomShocks1_zlbReg_intRate','figures'); 
  
% 
% 
% 
% 
% figure('Name','AR(1) Shock Process, Output Gap');
% plot(Date(plot_start:end),SS_est_avg_D(4,plot_start:end));
% hold on;
% filled = [SS_est_LB_D(4,plot_start:end),fliplr(SS_est_UB_D(4,plot_start:end))];
% Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
% fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
% xlim([Date(plot_start) Date(end)]);
%   set(gca,'xtick',DateTick)
%   datetick('x','yy','keepticks');   
  
% 
% 
% figure('Name','AR(1) Shock Process, Inflation');
% plot(Date(plot_start:end),SS_est_avg_D(5,plot_start:end));
% hold on;
% filled = [SS_est_LB_D(5,plot_start:end),fliplr(SS_est_UB_D(5,plot_start:end))];
% Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
% fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
% xlim([Date(plot_start) Date(end)]);
%   set(gca,'xtick',DateTick)
%   datetick('x','yy','keepticks');   
%   
%   
% figure('Name','iid shock, output gap');
% plot(Date(plot_start:end),eta_all_avg_D(plot_start:end,1,1));
% xlim([Date(plot_start) Date(end)]);
%   set(gca,'xtick',DateTick)
%   datetick('x','yy','keepticks'); 
%   
% figure('Name','iid shock, inflation');
% plot(Date(plot_start:end),eta_all_avg_D(plot_start:end,2,1));
% xlim([Date(plot_start) Date(end)]);
%   set(gca,'xtick',DateTick)
%   datetick('x','yy','keepticks');   



%======================================================================================================================
%=====================FIGURES FOR SIMULATIONS CLASSIFIED AS NORMAL

figure('Name','Fraction learning');
filled = [n1_UB_N(plot_start:end)',fliplr(n1_LB_N(plot_start:end)')];
Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
hold on;
plot(Date(plot_start:end),n1_avg_N(plot_start:end),'--','color','black','lineWidth',2);
ylim([0 1]);
hold on;
regimes_box(n1_avg_N(plot_start:end),CF_period,Date); 

xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');  
     xlabel('Date','FontSize',14);
  ylabel('n_t^L','FontSize',14);
  set(gca,'FontSize',14);
 generate_figures('var1_CF3_randomShocks1_normalReg_n1','figures'); 
  



figure('Name','Normal regime probability');
plot(Date(plot_start:end),P_normal_est_avg_N(plot_start:end),'--','color','black','lineWidth',2);
ylim([0 1]);
hold on;
regimes_box(P_normal_est_avg_N(plot_start:end),CF_period,Date); 
% hold on;
% filled = [P_normal_est_UB_N(plot_start:end),fliplr(P_normal_est_LB_N(plot_start:end))];
% Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
% fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks'); 
       xlabel('Date','FontSize',14);
  ylabel('Taylor Rule Probability','FontSize',14);
  set(gca,'FontSize',14);
 generate_figures('var1_CF3_randomShocks1_normalReg_regimeProb','figures'); 
  


figure('Name','Average Output Gap');
filled = [SS_est_LB_N(1,plot_start:end),fliplr(SS_est_UB_N(1,plot_start:end))];
Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
hold on;
plot(Date(plot_start:end),SS_est_avg_N(1,plot_start:end),'--','color','black','lineWidth',2);
ylim([-35 15]);
hold on;
regimes_box(SS_est_avg_N(1,plot_start:end),CF_period,Date); 

xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');  
       xlabel('Date','FontSize',14);
  ylabel('Output Gap','FontSize',14);
  set(gca,'FontSize',14);
   generate_figures('var1_CF3_randomShocks1_normalReg_gap','figures'); 
  
%   
figure('Name','Average Inflation');

filled = [pi_bar+SS_est_LB_N(2,plot_start:end),pi_bar+fliplr(SS_est_UB_N(2,plot_start:end))];
Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
hold on;
plot(Date(plot_start:end),pi_bar+SS_est_avg_N(2,plot_start:end),'--','color','black','lineWidth',2);
ylim([-3 4]);
hold on;
regimes_box(pi_bar+SS_est_avg_N(2,plot_start:end),CF_period,Date);

xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');   
         xlabel('Date','FontSize',14);
  ylabel('Inflation','FontSize',14);
  set(gca,'FontSize',14);
   generate_figures('var1_CF3_randomShocks1_normalReg_pi','figures'); 
  
%   
%   
% 
figure('Name','Average Shadow Rate');
filled = [(r_bar1-r_bar2)+shadow_rate_UB_N(plot_start:end)',(r_bar1-r_bar2)+fliplr(shadow_rate_LB_N(plot_start:end)')];
Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
ylim([-2.5 5]);
hold on;
plot(Date(plot_start:end),(r_bar1-r_bar2)+shadow_rate_avg_N(plot_start:end),'--','color','black','lineWidth',2);
hold on;
regimes_box((r_bar1-r_bar2)+shadow_rate_avg_N(plot_start:end),CF_period,Date);

xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');  
         xlabel('Date','FontSize',14);
  ylabel('Shadow Rate','FontSize',14);
  set(gca,'FontSize',14);
   generate_figures('var1_CF3_randomShocks1_normalReg_SR','figures'); 
  
% 
figure('Name','Average Nominal Interest rate');
filled = [(r_bar1-r_bar2)+SS_est_LB_N(3,plot_start:end),(r_bar1-r_bar2)+fliplr(SS_est_UB_N(3,plot_start:end))];
Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
hold on;
plot(Date(plot_start:end),(r_bar1-r_bar2)+SS_est_avg_N(3,plot_start:end),'--','color','black','lineWidth',2);
ylim([-0.5 5]);
hold on;
regimes_box((r_bar1-r_bar2)+SS_est_avg_N(3,plot_start:end),CF_period,Date);

xlim([Date(plot_start) Date(end)]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');   
         xlabel('Date','FontSize',14);
  ylabel('Nominal Interest Rate','FontSize',14);
  set(gca,'FontSize',14);
   generate_figures('var1_CF3_randomShocks1_normalReg_intRate','figures'); 
  
  
% 
% 
% 
% 
% figure('Name','AR(1) Shock Process, Output Gap');
% plot(Date(plot_start:end),SS_est_avg_N(4,plot_start:end));
% hold on;
% filled = [SS_est_LB_N(4,plot_start:end),fliplr(SS_est_UB_N(4,plot_start:end))];
% Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
% fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
% xlim([Date(plot_start) Date(end)]);
%   set(gca,'xtick',DateTick)
%   datetick('x','yy','keepticks');   
  
% 
% 
% figure('Name','AR(1) Shock Process, Inflation');
% plot(Date(plot_start:end),SS_est_avg_N(5,plot_start:end));
% hold on;
% filled = [SS_est_LB_N(5,plot_start:end),fliplr(SS_est_UB_N(5,plot_start:end))];
% Date2 = [Date(plot_start:end),fliplr(Date(plot_start:end))];
% fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
% xlim([Date(plot_start) Date(end)]);
%   set(gca,'xtick',DateTick)
%   datetick('x','yy','keepticks');   
%   
%   
% figure('Name','iid shock, output gap');
% plot(Date(plot_start:end),eta_all_avg_N(plot_start:end,1,1));
% xlim([Date(plot_start) Date(end)]);
%   set(gca,'xtick',DateTick)
%   datetick('x','yy','keepticks'); 
%   
% figure('Name','iid shock, inflation');
% plot(Date(plot_start:end),eta_all_avg_N(plot_start:end,2,1));
% xlim([Date(plot_start) Date(end)]);
%   set(gca,'xtick',DateTick)
%   datetick('x','yy','keepticks');   



