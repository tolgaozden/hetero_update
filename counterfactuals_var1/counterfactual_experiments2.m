clear;clc;%close all;
% load counterfactual_initials;
% % load estimation_results_march15.mat;
% % load mcmc_results_final.mat;
% rng(1);
% % parameters=posteriorMean';
% pi_bar = parameters(1);
% r_bar1 = parameters(2);
% r_bar2 = parameters(16);
% %simul_type: 
% %1= reproduce the benchmark scenario, both gain and n1 stay at estimated
% %values
% %2=n1 endogenously determined (estimated case), gain is set by user
% %3= n1 set by the user, gain is fixed at the estimated value
% %4= both n1 and gain are set by the user
% 
% simul_LB = [-1e5 -1e5 -1e5 -1e5 ] ;
% simul_UB = [ 100 100 100 100];
% 
% n1 = 0;
% gain = parameters(20);
% CF_start=108;
% simul_type=1;
% T = length(S_filtered);
% % startDate=datenum('01-06-1982');
% % endDate = datenum('01-12-2024');
% %IMPORTANT: ACTUAL DATES ARE 1-06-1982 and 01-12-2014 respectively.
% %the figures marks the year by end-of-the-year-quarter whereas I would like to
% %mark them by beginning-of-the-year-quarterly, so I shift the axis forward
% %by 1 year.
% % startDate=datenum('01-04-1983');
% % endDate = datenum('01-10-2019');
% 
% startDate=datenum('01-01-1984');
% endDate = datenum('01-7-2020');
% 
% Date=linspace(startDate,endDate,T-1);
% Date  = Date(CF_start:end);
% DateTick = linspace(Date(1),Date(end),floor(T/20));
% 
% 
% 
% [explosive_indicator_benchmark,SS_benchmark,PP_benchmark,shadow_rate_benchmark,n1_benchmark,alpha1_tt_benchmark,beta1_tt_benchmark] =...
%     counterfactual_function(simul_LB,simul_UB,n1,gain,CF_start,simul_type);
% 
% %descriptive statistics benchmark case
% mean_benchmark= [mean(SS_benchmark(:,CF_start:end)')' ;
%     mean(shadow_rate_benchmark(CF_start:end))];
% 
% 
% %========================== 1D grid search for n1
% %================================================
% 
% simul_type = 3; %checking how counterfactuals change with different n1 fractions
% 
% numSimul = 1000 ; 
% gain_grid = linspace(0,0.02,numSimul);
% n1_grid = linspace(0,0.9,numSimul);
% 
% % counter=0;
% tic;
% 
% parfor jj=1:numSimul
% %         counter=counter+1;
% %         disp(counter);
% 
% %     gain = gain_grid(jj);
% 	gain = gain_grid(jj);
%     n1=n1_grid(jj);
% 
% [explosive_indicator,SS,PP,shadow_rate,n1,alpha1_tt,beta1_tt] =...
%     counterfactual_function(simul_LB,simul_UB,n1,gain,CF_start,simul_type);
% 
% mean_simul(jj,:)= [mean(SS(:,CF_start:end)')' ;
%     mean(shadow_rate(CF_start:end))];
% 
%  SS_all(:,:,jj) = SS(:,CF_start:end)';
% 
% n1_simul(jj,:) = n1(CF_start:end);
% PP_simul(:,:,jj) = PP(:,CF_start:end);
% exp_ind(jj) = explosive_indicator;
% 
% end
% 
% save counterfactual_experiments2_data.mat;
load counterfactual_experiments2_data.mat;



% toc
xx_length = size(n1_simul,2);
yy_length = size(n1_simul,1);

refLine1 = linspace(n1_grid(1),n1_grid(end),yy_length); refLine1 = repmat(refLine1,[xx_length 1]);
refLine2 = linspace(Date(1),Date(end),xx_length); refLine2 = repmat(refLine2,[yy_length 1])';


gap_CF = squeeze(SS_all(:,1,:));
infl_CF= squeeze(SS_all(:,2,:));
SR_CF = squeeze(SS_all(:,9,:));

P1_CF = squeeze(PP_simul(1,:,:));
P2_CF = squeeze(PP_simul(2,:,:));
P3_CF = squeeze(PP_simul(3,:,:));
P4_CF = squeeze(PP_simul(4,:,:));

figure('Name','Output Gap-Period Specific');
% plot3(refLine1,refLine2,gap_CF,'--','color','black','lineWidth',0.1);
 pp1= mesh(refLine1,refLine2,gap_CF,'LineStyle',':','FaceAlpha',0.1);
hold on;
% pp2=mesh(refLine1,refLine2,repmat(SS_benchmark(1,CF_start:end),[numSimul 1])','FaceAlpha',0.1,'EdgeColor','red');
plot3(refLine1(:,1),refLine2(:,1),SS_benchmark(1,CF_start:end),'lineWidth',5','color','black');

ylim([Date(1) Date(end)]);
  set(gca,'ytick',DateTick)
  datetick('y','yy','keepticks');
%   set(gca,'view',[54 30]);
set(gca,'view',[126 30]);
grid off;
xlabel('n_t^L');
ylabel('Date');
zlabel('Output Gap');
set(gca,'FontSize',14);
generate_figures('var1_CF1_fixedShocks_gap','figures'); 



figure('Name','Output Gap Mean');
plot(n1_grid,mean_simul(:,1),'-.','color','black','lineWidth',3);
hold on;
plot(n1_grid,mean_benchmark(1) * ones(length(n1_grid)),'--','color','blue');
xlabel('n_t^L');
ylabel('Average Output Gap, 09Q2-19Q4');
set(gca,'FontSize',14);
xlim([n1_grid(1) n1_grid(end)]);
generate_figures('var1_CF1_fixedShocks_gapMean','figures'); 


figure('Name','Inflation-Period Specific');
% plot3(refLine1,refLine2,gap_CF,'--','color','black','lineWidth',0.1);
 pp1= mesh(refLine1,refLine2,pi_bar+infl_CF,'LineStyle',':','FaceAlpha',0.1);
hold on;
plot3(refLine1(:,1),refLine2(:,1),pi_bar+SS_benchmark(2,CF_start:end),'lineWidth',5','color','black');
ylim([Date(1) Date(end)]);
  set(gca,'ytick',DateTick)
  datetick('y','yy','keepticks');
%   set(gca,'view',[54 30]);
set(gca,'view',[126 30]);
grid off;
xlabel('n_t^L');
ylabel('Date');
zlabel('Inflation');
set(gca,'FontSize',14);
xlim([n1_grid(1) n1_grid(end)]);
generate_figures('var1_CF1_fixedShocks_pi','figures'); 


figure('Name','Inflation Mean');
plot(n1_grid,pi_bar+mean_simul(:,2),'-.','color','black','lineWidth',3);
hold on;
plot(n1_grid,pi_bar+mean_benchmark(2) * ones(length(n1_grid)),'--','color','blue');
xlabel('n_t^L');
ylabel('Average Inflation, 09Q2-19Q4');
set(gca,'FontSize',14);
xlim([n1_grid(1) n1_grid(end)]);
generate_figures('var1_CF1_fixedShocks_piMean','figures'); 


figure('Name','Shadow Rate-Period Specific');
% plot3(refLine1,refLine2,gap_CF,'--','color','black','lineWidth',0.1);
 pp1= mesh(refLine1,refLine2,(r_bar1-r_bar2)+SR_CF,'LineStyle',':','FaceAlpha',0.1);
hold on;
plot3(refLine1(:,1),refLine2(:,1),(r_bar1-r_bar2)+SS_benchmark(9,CF_start:end),'lineWidth',5','color','black');
ylim([Date(1) Date(end)]);
  set(gca,'ytick',DateTick)
  datetick('y','yy','keepticks');
%   set(gca,'view',[54 30]);
set(gca,'view',[126 30]);
grid off;
xlabel('n_t^L');
ylabel('Date');
zlabel('Shadow Rate');
set(gca,'FontSize',14);
xlim([n1_grid(1) n1_grid(end)]);
generate_figures('var1_CF1_fixedShocks_SR','figures'); 


figure('Name','Shadow Rate Mean');
plot(n1_grid,(r_bar1-r_bar2)+mean_simul(:,9),'-.','color','black','lineWidth',3);
hold on;
plot(n1_grid,(r_bar1-r_bar2)+mean_benchmark(9) * ones(length(n1_grid)),'--','color','blue');
xlabel('n_t^L');
ylabel('Average Shadow Rate, 09Q2-19Q4');
set(gca,'FontSize',14);
xlim([n1_grid(1) n1_grid(end)]);
generate_figures('var1_CF1_fixedShocks_SRMean','figures'); 
%============================================================================================
figure('Name','Taylor Rule Probability-Period Specific');
plot3(refLine1,refLine2,(P1_CF+P2_CF),':','color','black','lineWidth',0.1);
%  pp1= mesh(refLine1,refLine2,(P1_CF+P2_CF),'LineStyle',':','FaceAlpha',0.1);
hold on;
plot3(refLine1(:,1),refLine2(:,1),(PP_benchmark(1,CF_start:end)+PP_benchmark(2,CF_start:end)),'lineWidth',3','color','red');
ylim([Date(1) Date(end)]);
  set(gca,'ytick',DateTick)
  datetick('y','yy','keepticks');
%   set(gca,'view',[54 30]);
set(gca,'view',[  -60    46]);
grid off;
xlabel('n_t^L');
ylabel('Date');
zlabel('Probability of Taylor Regime');
set(gca,'FontSize',14);
xlim([n1_grid(1) n1_grid(end)]);
generate_figures('var1_CF1_fixedShocks_probTaylor','figures'); 


figure('Name','Average Probability of Taylor Regime');
plot(n1_grid,mean(P1_CF+P2_CF,1),'-','color','black','lineWidth',1);
hold on;
plot(n1_grid,mean(P1_CF(1:end-4,:)+P2_CF(1:end-4,:)),'--','color','black','lineWidth',1);
hold on;
plot(n1_grid,mean(P1_CF(1:end-8,:)+P2_CF(1:end-8,:)),'--','color','red','lineWidth',1);
hold on;
plot(n1_grid,mean(P1_CF(1:end-12,:)+P2_CF(1:end-12,:)),'--','color','yellow','lineWidth',1);
hold on;
plot(n1_grid,mean(P1_CF(1:end-16,:)+P2_CF(1:end-16,:)),'--','color','green','lineWidth',1);
hold on;
plot(n1_grid,mean(P1_CF(1:end-20,:)+P2_CF(1:end-20,:)),'--','color','blue','lineWidth',1);

xlabel('n_t^L');
ylabel('Average Probability of Taylor Regime over Different Periods','FontSize',10);
% ylabel('Average Probability of Taylor Regime, 09Q2-19Q4');
leg_temp=legend('09Q2-19Q4','09Q2-18Q4','09Q2-17Q4','09Q2-16Q4','09Q2-15Q4','09Q2-14Q4');
pos_leg =leg_temp.Position;
% text(pos_leg(1),pos_leg(2),'Average Probability of Taylor Regime:');
set(gca,'FontSize',14);
xlim([n1_grid(1) n1_grid(end)]);
    generate_figures('var1_CF1_fixedShocks_probTaylorMean','figures'); 


    %   figure('Name','Taylor Rule Regime Probability');
    % plot3(refLine1,refLine2,(P1_CF+P2_CF),'-','color','black','lineWidth',0.5);
    % hold on;
    % plot3(refLine1(:,1),refLine2(:,1),(PP_benchmark(1,CF_start:end)+PP_benchmark(2,CF_start:end))','lineWidth',3','color','red');
    % ylim([Date(1) Date(end)]);
    %   set(gca,'ytick',DateTick)
    %   datetick('y','yy','keepticks');
    %   set(gca,'view',[54 30]);




    % figure('Name',' ZLB Regime (Inactive Policy)');
    % plot3(refLine1',refLine2',(P3_CF+P4_CF)','*','color','black','lineWidth',0.5);
    % ylim([Date(1) Date(end)]);
    %   set(gca,'ytick',DateTick)
    %   datetick('y','yy','keepticks');  
    %   set(gca,'view',[54 30]);   
    %   


    %=============================================================

    %========================== 1D grid search for gain
    %================================================

    % simul_type = 2;
    % 
    % numSimul = 20 ; 
    % gain_grid = linspace(0,0.02,numSimul);
    % n1_grid = linspace(0,0.9,numSimul);
% 
% counter=0;
% tic;
% 
% for jj=1:numSimul
%         counter=counter+1;
%         disp(counter);
% 
% %     gain = gain_grid(jj);
% 	gain = gain_grid(jj);
%     n1=n1_grid(jj);
% 
% [explosive_indicator,SS,PP,shadow_rate,n1,alpha1_tt,beta1_tt] =...
%     counterfactual_function(simul_LB,simul_UB,n1,gain,CF_start,simul_type);
% 
% mean_simul(jj,:)= [mean(SS(:,CF_start:end)')' ;
%     mean(shadow_rate(CF_start:end))];
% 
%  SS_all(:,:,jj) = SS(:,CF_start:end)';
% 
% n1_simul(jj,:) = n1(CF_start:end);
% PP_simul(:,:,jj) = PP(:,CF_start:end);
% 
% end
% 
% xx_length = size(n1_simul,2);
% yy_length = size(n1_simul,1);
% 
% refLine1 = linspace(gain_grid(1),gain_grid(end),yy_length); refLine1 = repmat(refLine1,[xx_length 1]);
% refLine2 = linspace(Date(1),Date(end),xx_length); refLine2 = repmat(refLine2,[yy_length 1])';
% 
% 
% gap_CF = squeeze(SS_all(:,1,:));
% infl_CF= squeeze(SS_all(:,2,:));
% SR_CF = squeeze(SS_all(:,9,:));
% 
% P1_CF = squeeze(PP_simul(1,:,:));
% P2_CF = squeeze(PP_simul(2,:,:));
% P3_CF = squeeze(PP_simul(3,:,:));
% P4_CF = squeeze(PP_simul(4,:,:));
% 
% figure('Name','Output Gap-Period Specific');
% plot3(refLine1',refLine2',gap_CF','color','black','lineWidth',0.5);
% ylim([Date(1) Date(end)]);
%   set(gca,'ytick',DateTick)
%   datetick('y','yy','keepticks');
%   set(gca,'view',[54 30]);
%   
% figure('Name','Inflation-Period Specific');
% plot3(refLine1',refLine2',infl_CF','color','black','lineWidth',0.5);
% ylim([Date(1) Date(end)]);
%   set(gca,'ytick',DateTick)
%   datetick('y','yy','keepticks');  
%   set(gca,'view',[54 30]);
%   
% figure('Name','Shadow Rate-Period Specific');
% plot3(refLine1',refLine2',SR_CF','color','black','lineWidth',0.5);
% ylim([Date(1) Date(end)]);
%   set(gca,'ytick',DateTick)
%   datetick('y','yy','keepticks');  
%   set(gca,'view',[54 30]);
%   
%  figure('Name','Normal Regime (Taylor Rule)');
% plot3(refLine1',refLine2',(P1_CF+P2_CF)','color','black','lineWidth',0.5);
% ylim([Date(1) Date(end)]);
%   set(gca,'ytick',DateTick)
%   datetick('y','yy','keepticks');  
%   set(gca,'view',[54 30]); 
%   
%   
% figure('Name',' ZLB Regime (Inactive Policy)');
% plot3(refLine1',refLine2',(P3_CF+P4_CF)','color','black','lineWidth',0.5);
% ylim([Date(1) Date(end)]);
%   set(gca,'ytick',DateTick)
%   datetick('y','yy','keepticks');  
%   set(gca,'view',[54 30]);   
%   
% 
% 
% figure('Name','Output Gap Mean');
% plot(gain_grid,mean_simul(:,1),'color','black','lineWidth',3);
% hold on;
% plot(gain_grid,mean_benchmark(1) * ones(length(gain_grid)),'--','color','red');
% 
% figure('Name','Inflation Mean');
% plot(gain_grid,mean_simul(:,2),'color','black','lineWidth',3);
% hold on;
% plot(gain_grid,mean_benchmark(2) * ones(length(gain_grid)),'--','color','red');
% 
% figure('Name','Shadow Rate Mean');
% plot(gain_grid,mean_simul(:,9),'color','black','lineWidth',3);
% hold on;
% plot(gain_grid,mean_benchmark(9) * ones(length(gain_grid)),'--','color','red');




% figure;
% index=0;
% for jj=[1 2 10]
%     index=index+1;
%     subplot(3,1,index);
% plot(n1_grid,mean_simul(jj,:));
% hold on;
% plot(n1_grid,ones(length(n1_grid),1)*mean_benchmark(jj));
% end



% figure;
% plot(S_filtered(2:end,1));
% hold on;
% plot(SS_benchmark(1,2:end));
% legend('actual','counterfactual');
% title('output gap');
% 
% figure;
% plot(S_filtered(2:end,2));
% hold on;
% plot(SS_benchmark(2,2:end));
% legend('actual','counterfactual');
% title('inflation');
% 
% figure;
% plot(S_filtered(2:end,4));
% hold on;
% plot(SS_benchmark(4,2:end));
% legend('actual','counterfactual');
% title('exogenous shock--output gap');
% 
% figure;
% plot(S_filtered(2:end,5));
% hold on;
% plot(SS_benchmark(5,2:end));
% legend('actual','counterfactual');
% title('exogenous shock--inflation');
% 
% 
% figure;
% plot(S_filtered(2:end,3));
% hold on;
% plot(SS_benchmark(3,2:end));
% legend('actual','counterfactual');
% title('nominal rates');
% 
% 
% figure;
% plot(shadow_rate_filtered(2:end));
% hold on;
% plot(shadow_rate_benchmark(2:end));
% hold on;
% plot(ones(length(shadow_rate_filtered(2:end)),1)*(-r_bar1+r_bar2));
% legend('estimated','counterfactual');
% title('shadow_rate');
% % 
% figure;
% plot(n1_filtered(2:end));
% hold on;
% plot(n1_benchmark(2:end));
% legend('estimated','counterfactual');
% title('fraction--learning');
% 
% 
% 
% figure;
% subplot(3,2,1);
% area(PP_benchmark(1,:));
% 
% subplot(3,2,2);
% area(PP_benchmark(2,:));
% 
% subplot(3,2,3);
% area(PP_benchmark(3,:));
% 
% subplot(3,2,4);
% area(PP_benchmark(4,:));
% 
% subplot(3,2,5);
% area(PP_benchmark(1,:)+PP_benchmark(2,:));
% ylim([0 1]);
% 
% subplot(3,2,6);
% area(PP_benchmark(3,:)+PP_benchmark(4,:));
% ylim([0 1]);

% 
% figure;
% plot(projectionFlag);
