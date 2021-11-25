clear;clc;%close all;
load counterfactual_initials;
rng(1);
% load estimation_results_march15.mat;
r_bar1 = parameters(2);
r_bar2 =parameters(16);
%simul_type: 
%1= reproduce the benchmark scenario, both gain and n1 stay at estimated
%values
%2=n1 endogenously determined (estimated case), gain is set by user
%3= n1 set by the user, gain is fixed at the estimated value
%4= both n1 and gain are set by the user

simul_LB = [-1e5 -1e5 -1e5 -1e5 ] ;
simul_UB = [ 100 100 100 100];

mh_conf = 0.90;
n1 = 0;
gain = parameters(20);
CF_start=111;
numSimul=1000;
simul_type=1;
iid_indicator=1;
T = length(S_filtered);

LB_index = round((1-mh_conf)*numSimul);
UB_index = round((mh_conf)*numSimul);

% startDate=datenum('01-06-1982');
% endDate = datenum('01-12-2024');
%IMPORTANT: ACTUAL DATES ARE 1-06-1982 and 01-12-2014 respectively.
%the figures marks the year by end-of-the-year-quarter whereas I would like to
%mark them by beginning-of-the-year-quarterly, so I shift the axis forward
%by 1 year.
startDate=datenum('01-04-1983');
endDate = datenum('01-10-2025');
Date=linspace(startDate,endDate,T);
% Date  = Date(CF_start:end);
DateTick = linspace(Date(CF_start),Date(end),floor(T/20));



[explosive_indicator_benchmark,SS_benchmark,PP_benchmark,shadow_rate_benchmark,n1_benchmark,alpha1_tt_benchmark,beta1_tt_benchmark,prFlag_benchmark] =...
    counterfactual_function(simul_LB,simul_UB,n1,gain,CF_start,simul_type);

%descriptive statistics benchmark case
mean_benchmark= [mean(SS_benchmark(:,CF_start:end)')' ;
    mean(shadow_rate_benchmark(CF_start:end))];


P_normal_benchmark = PP_benchmark(1,:) + PP_benchmark(2,:);
P_zlb_benchmark    = PP_benchmark(3,:) + PP_benchmark(4,:);

%==============================benchmark scenario with fixed n1 (endogenous determined)============================================
% CF_start = 110;
simul_type = 1;
CF_length = T-CF_start+1;



 seed_grid = round(5000*rand(numSimul,1))

for jj=1:numSimul
      disp(jj)
seed_ = seed_grid(jj);
gain = parameters(20);
n1 = 0.1;
T = length(S_filtered);




[explosive_indicator,SS,PP,shadow_rate n1,alpha1_tt,beta1_tt,pr_flag] =...
    counterfactual_function_rnd(simul_LB,simul_UB,n1,gain,CF_start,simul_type,CF_length,seed_,iid_indicator);

P_normal_est(:,jj) = (PP(1,:) + PP(2,:))';
P_zlb_est(:,jj)   = (PP(3,:) + PP(4,:))';
pr_flag_est(:,jj) = pr_flag;
SS_all_est(:,:,jj) = SS;

end

%averages
P_normal_est_avg = mean(P_normal_est,2);
P_zlb_est_avg = mean(P_zlb_est,2);
pr_flag_est_avg= mean(pr_flag_est,2);
SS_est_avg = mean(SS_all_est,3);

%sorted matrices
P_normal_est_sorted = sort(P_normal_est,2);
P_zlb_est_sorted = sort(P_zlb_est,2);
pr_flag_est_sorted =sort(pr_flag_est,2);
SS_all_est_sorted = sort(SS_all_est,3);

%lb
P_normal_est_LB = P_normal_est_sorted(:,LB_index);
P_zlb_est_LB = P_zlb_est_sorted(:,LB_index);
pr_flag_est_LB = pr_flag_est_sorted(:,LB_index);
SS_all_est_LB = SS_all_est_sorted(:,:,LB_index);


%ub
P_normal_est_UB = P_normal_est_sorted(:,UB_index);
P_zlb_est_UB = P_zlb_est_sorted(:,UB_index);
pr_flag_est_UB = pr_flag_est_sorted(:,UB_index);
SS_all_est_UB = SS_all_est_sorted(:,:,UB_index);


%==============================n1 fixed at a high value, 0.9============================================

% CF_start = 110;
simul_type = 3;
CF_length = T-CF_start+1;


for jj=1:numSimul
      disp(jj)
seed_ = seed_grid(jj);
gain = 0.01;
n1= 0.9;
T = length(S_filtered);




[explosive_indicator,SS,PP,shadow_rate n1,alpha1_tt,beta1_tt,pr_flag] =...
    counterfactual_function_rnd(simul_LB,simul_UB,n1,gain,CF_start,simul_type,CF_length,seed_,iid_indicator);

P_normal_n90(:,jj) = (PP(1,:) + PP(2,:))';
P_zlb_n90(:,jj)   = (PP(3,:) + PP(4,:))';
SS_all_n90(:,:,jj) = SS;
pr_flag_n90(:,jj) = pr_flag;
end

P_normal_n90_avg = mean(P_normal_n90,2);
P_zlb_n90_avg = mean(P_zlb_n90,2);
pr_flag_n90_avg= mean(pr_flag_n90,2);
SS_n90_avg = mean(SS_all_n90,3);


%sorted matrices
P_normal_n90_sorted = sort(P_normal_n90,2);
P_zlb_n90_sorted = sort(P_zlb_n90,2);
pr_flag_n90_sorted =sort(pr_flag_n90,2);
SS_all_n90_sorted = sort(SS_all_n90,3);

%lb
P_normal_n90_LB = P_normal_n90_sorted(:,LB_index);
P_zlb_n90_LB = P_zlb_n90_sorted(:,LB_index);
pr_flag_n90_LB = pr_flag_n90_sorted(:,LB_index);
SS_all_n90_LB = SS_all_n90_sorted(:,:,LB_index);


%ub
P_normal_n90_UB = P_normal_n90_sorted(:,UB_index);
P_zlb_n90_UB = P_zlb_n90_sorted(:,UB_index);
pr_flag_n90_UB = pr_flag_n90_sorted(:,UB_index);
SS_all_n90_UB = SS_all_n90_sorted(:,:,UB_index);

%==============================n1 fixed at a high value, 0.1============================================

% CF_start = 110;
simul_type = 3;
CF_length = T-CF_start+1;


for jj=1:numSimul
    disp(jj)
seed_ = seed_grid(jj);
gain = 0.001;
n1 = 0.1;
T = length(S_filtered);




[explosive_indicator,SS,PP,shadow_rate, n1,alpha1_tt,beta1_tt,pr_flag] =...
    counterfactual_function_rnd(simul_LB,simul_UB,n1,gain,CF_start,simul_type,CF_length,seed_,iid_indicator);

P_normal_n10(:,jj) = (PP(1,:) + PP(2,:))';
P_zlb_n10(:,jj)   = (PP(3,:) + PP(4,:))';
pr_flag_n10(:,jj) = pr_flag;
SS_all_n10(:,:,jj) = SS;


end

P_normal_n10_avg = mean(P_normal_n10,2);
P_zlb_n10_avg = mean(P_zlb_n10,2);
pr_flag_n10_avg= mean(pr_flag_n10,2);
SS_n10_avg = mean(SS_all_n10,3);

%sorted matrices
P_normal_n10_sorted = sort(P_normal_n10,2);
P_zlb_n10_sorted = sort(P_zlb_n10,2);
pr_flag_n10_sorted =sort(pr_flag_n10,2);
SS_all_n10_sorted = sort(SS_all_n10,3);

%lb
P_normal_n10_LB = P_normal_n10_sorted(:,LB_index);
P_zlb_n10_LB = P_zlb_n10_sorted(:,LB_index);
pr_flag_n10_LB = pr_flag_n10_sorted(:,LB_index);
SS_all_n10_LB = SS_all_n10_sorted(:,:,LB_index);


%ub
P_normal_n10_UB = P_normal_n10_sorted(:,UB_index);
P_zlb_n10_UB = P_zlb_n10_sorted(:,UB_index);
pr_flag_n10_UB = pr_flag_n10_sorted(:,UB_index);
SS_all_n10_UB = SS_all_n10_sorted(:,:,UB_index);

%==============================n1 fixed at a high value, 0.5============================================

% CF_start = 110;
simul_type = 3;
CF_length = T-CF_start+1;


for jj=1:numSimul
    disp(jj)
seed_ = seed_grid(jj);
gain = 0.01;
n1 = 0.7;
T = length(S_filtered);




[explosive_indicator,SS,PP,shadow_rate, n1,alpha1_tt,beta1_tt,pr_flag] =...
    counterfactual_function_rnd(simul_LB,simul_UB,n1,gain,CF_start,simul_type,CF_length,seed_,iid_indicator);

P_normal_n50(:,jj) = (PP(1,:) + PP(2,:))';
P_zlb_n50(:,jj)   = (PP(3,:) + PP(4,:))';
pr_flag_n50(:,jj) = pr_flag;
SS_all_n50(:,:,jj) = SS;


end





P_normal_n50_avg = mean(P_normal_n50,2);
P_zlb_n50_avg = mean(P_zlb_n50,2);
pr_flag_n50_avg= mean(pr_flag_n50,2);
SS_n50_avg = mean(SS_all_n50,3);

%sorted matrices
P_normal_n50_sorted = sort(P_normal_n50,2);
P_zlb_n50_sorted = sort(P_zlb_n50,2);
pr_flag_n50_sorted =sort(pr_flag_n50,2);
SS_all_n50_sorted = sort(SS_all_n50,3);

%lb
P_normal_n50_LB = P_normal_n50_sorted(:,LB_index);
P_zlb_n50_LB = P_zlb_n50_sorted(:,LB_index);
pr_flag_n50_LB = pr_flag_n50_sorted(:,LB_index);
SS_all_n50_LB = SS_all_n50_sorted(:,:,LB_index);


%ub
P_normal_n50_UB = P_normal_n50_sorted(:,UB_index);
P_zlb_n50_UB = P_zlb_n50_sorted(:,UB_index);
pr_flag_n50_UB = pr_flag_n50_sorted(:,UB_index);
SS_all_n50_UB = SS_all_n50_sorted(:,:,UB_index);


save counterfactual_experiments5_data.mat;
load counterfactual_experiments5_data.mat;




figure;
plot(Date(CF_start:end),(pp_filtered(CF_start:end,1)+pp_filtered(CF_start:end,2)),'--','color','black');
hold on;
plot(Date(CF_start:end),P_normal_est_avg(CF_start:end),'*','color','red','lineWidth',0.1);
hold on;
plot(Date(CF_start:end),P_normal_n90_avg(CF_start:end),'-','color','magenta');
hold on;
plot(Date(CF_start:end),P_normal_n10_avg(CF_start:end),'.-','color','blue');
hold on;
plot(Date(CF_start:end),P_normal_n50_avg(CF_start:end),'.','color','green');
leg=legend('Empirical','Estimated Fractions','90% de-anchored','10% de-anchored','50% de-anchored%');
leg.Position =  [0.134528287842979 0.713492069168696 0.291071422877056 0.209523803847177];
xlim([Date(CF_start) Date(end)]);
ylim([0 1]);
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');  
  ylabel('Probability of Taylor Regime');
  xlabel('Date');
set(gca,'FontSize',14);
 generate_figures('ar1_CFext_fixedShocks_regimeProb','figures');    




% 
figure('Name','Output Gap Projections, estimated fractions');
plot(Date(CF_start:end),SS_est_avg(1,CF_start:end),'color','black','lineWidth',2);
hold on;
plot(Date(CF_start:end),SS_benchmark(1,CF_start:end),'--','color','red');
filled = [SS_all_est_UB(1,CF_start:end),fliplr(SS_all_est_LB(1,CF_start:end))];
Date2 = [Date(CF_start:end),fliplr(Date(CF_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
legend('Projection','Data','90 CI Band');
xlim([Date(CF_start) Date(end)]);
set(gca,'xtick',DateTick)
datetick('x','yy','keepticks');    

  
  
figure('Name','Output Gap Projections, 90% learning agents');
plot(Date(CF_start:end),SS_n90_avg(1,CF_start:end),'color','black','lineWidth',2);
hold on;
plot(Date(CF_start:end),SS_benchmark(1,CF_start:end),'--','color','red');

filled = [SS_all_n90_UB(1,CF_start:end),fliplr(SS_all_n90_LB(1,CF_start:end))];
Date2 = [Date(CF_start:end),fliplr(Date(CF_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
legend('Projection','Data','90 CI Band');
xlim([Date(CF_start) Date(end)]);
set(gca,'xtick',DateTick)
datetick('x','yy','keepticks');  



  
figure('Name','Output Gap Projections, 50% learning agents');
plot(Date(CF_start:end),SS_n50_avg(1,CF_start:end),'color','black','lineWidth',2);
hold on;
plot(Date(CF_start:end),SS_benchmark(1,CF_start:end),'--','color','red');

filled = [SS_all_n50_UB(1,CF_start:end),fliplr(SS_all_n50_LB(1,CF_start:end))];
Date2 = [Date(CF_start:end),fliplr(Date(CF_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
legend('Projection','Data','90 CI Band');
xlim([Date(CF_start) Date(end)]);
set(gca,'xtick',DateTick)
datetick('x','yy','keepticks');   


% figure('Name','Output Gap Projections, 50% learning agents');
% plot(Date(CF_start:end),SS_n50_avg(1,CF_start:end),'color','black','lineWidth',2);
% hold on;
% plot(Date(CF_start:end),SS_benchmark(1,CF_start:end),'--','color','red');hold on;
% plot(Date(CF_start:end),SS_all_n50_LB(1,CF_start:end),'color','red','lineWidth',2);
% hold on;
% plot(Date(CF_start:end),SS_all_n50_UB(1,CF_start:end),'color','blue','lineWidth',2);
% xlim([Date(CF_start) Date(end)]);
% set(gca,'xtick',DateTick)
% datetick('x','yy','keepticks');   

  
figure('Name','Output Gap Projections, 10% learning agents');
plot(Date(CF_start:end),SS_n10_avg(1,CF_start:end),'color','black','lineWidth',2);
hold on;
plot(Date(CF_start:end),SS_benchmark(1,CF_start:end),'--','color','red');

filled = [SS_all_n10_UB(1,CF_start:end),fliplr(SS_all_n10_LB(1,CF_start:end))];
Date2 = [Date(CF_start:end),fliplr(Date(CF_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
legend('Projection','Data','90 CI Band');
xlim([Date(CF_start) Date(end)]);
set(gca,'xtick',DateTick)
datetick('x','yy','keepticks');  
  


figure('Name','Inflation Projections, estimated fractions');
plot(Date(CF_start:end),SS_est_avg(2,CF_start:end),'color','black','lineWidth',2);
hold on;
plot(Date(CF_start:end),SS_benchmark(2,CF_start:end),'--','color','red');

filled = [SS_all_est_UB(2,CF_start:end),fliplr(SS_all_est_LB(2,CF_start:end))];
Date2 = [Date(CF_start:end),fliplr(Date(CF_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
legend('Projection','Data','90 CI Band');
xlim([Date(CF_start) Date(end)]);
set(gca,'xtick',DateTick)
datetick('x','yy','keepticks');  
  
  
figure('Name','Inflation Projections, 90% learning agents');
plot(Date(CF_start:end),SS_n90_avg(2,CF_start:end),'color','black','lineWidth',2);
hold on;
plot(Date(CF_start:end),SS_benchmark(2,CF_start:end),'--','color','red');

filled = [SS_all_n90_UB(2,CF_start:end),fliplr(SS_all_n90_LB(2,CF_start:end))];
Date2 = [Date(CF_start:end),fliplr(Date(CF_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
legend('Projection','Data','90 CI Band');
xlim([Date(CF_start) Date(end)]);
set(gca,'xtick',DateTick)
datetick('x','yy','keepticks');  



  
figure('Name','Inflation Projections, 50% learning agents');
plot(Date(CF_start:end),SS_n50_avg(2,CF_start:end),'color','black','lineWidth',2);
hold on;
plot(Date(CF_start:end),SS_benchmark(2,CF_start:end),'--','color','red');

filled = [SS_all_n50_UB(2,CF_start:end),fliplr(SS_all_n50_LB(2,CF_start:end))];
Date2 = [Date(CF_start:end),fliplr(Date(CF_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
legend('Projection','Data','90 CI Band');
xlim([Date(CF_start) Date(end)]);
set(gca,'xtick',DateTick)
datetick('x','yy','keepticks');   

  
figure('Name','Inflation Projections, 10% learning agents');
plot(Date(CF_start:end),SS_n10_avg(2,CF_start:end),'color','black','lineWidth',2);
hold on;
plot(Date(CF_start:end),SS_benchmark(2,CF_start:end),'--','color','red');

filled = [SS_all_n10_UB(2,CF_start:end),fliplr(SS_all_n10_LB(2,CF_start:end))];
Date2 = [Date(CF_start:end),fliplr(Date(CF_start:end))];
fill(Date2,filled,[0 0 1],'EdgeColor',[1 1 1 ],'FaceAlpha',0.5,'EdgeAlpha',0.5);
legend('Projection','Data','90 CI Band');
xlim([Date(CF_start) Date(end)]);
set(gca,'xtick',DateTick)
datetick('x','yy','keepticks');  




% figure('Name','Average Inflation');
% plot(Date(CF_start:end),SS_est_avg(2,CF_start:end));
% hold on;
% plot(Date(CF_start:end),SS_n90_avg(2,CF_start:end));
% hold on;
% plot(Date(CF_start:end),SS_n10_avg(2,CF_start:end));
% hold on;
% plot(Date(CF_start:end),SS_benchmark(2,CF_start:end));
% hold on;
% plot(Date(CF_start:end),SS_n50_avg(2,CF_start:end));
% 
% xlim([Date(CF_start) Date(end)]);
%   set(gca,'xtick',DateTick)
%   datetick('x','yy','keepticks');  
% 
% legend('estimated fractions','90 % learning agents','10 % learning agents','empirical','learning agents 50 %');





% figure;
% plot(pr_flag_est_avg);
% hold on;
% plot(pr_flag_n90_avg);
% hold on;
% plot(pr_flag_n10_avg);
% legend('estimated fractions','90 % learning agents','10 % learning agents');

%  [mean(pr_flag_est_avg) mean(pr_flag_n90_avg) mean(pr_flag_n10_avg)])]