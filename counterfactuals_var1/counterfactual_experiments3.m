clear;clc;%close all;
load counterfactual_initials;
rng(1);
% load estimation_results_march15.mat;
pi_bar = parameters(1);
r_bar1 = parameters(2);
r_bar2 = parameters(16);
%simul_type: 
%1= reproduce the benchmark scenario, both gain and n1 stay at estimated
%values
%2=n1 endogenously determined (estimated case), gain is set by user
%3= n1 set by the user, gain is fixed at the estimated value
%4= both n1 and gain are set by the user

simul_LB = [-1e5 -1e5 -1e5 -1e5 ] ;
simul_UB = [ 100 100 100 100];

n1 = 0;
gain = parameters(20);
CF_start=108;
simul_type=1;
T = length(S_filtered);

% startDate=datenum('01-06-1982');
% endDate = datenum('01-12-2024');
%IMPORTANT: ACTUAL DATES ARE 1-06-1982 and 01-12-2014 respectively.
%the figures marks the year by end-of-the-year-quarter whereas I would like to
%mark them by beginning-of-the-year-quarterly, so I shift the axis forward
%by 1 year.
startDate=datenum('01-04-1983');
endDate = datenum('01-10-2025');

Date=linspace(startDate,endDate,T-1);
Date  = Date(CF_start:end);
DateTick = linspace(Date(1),Date(end),floor(T/20));



[explosive_indicator_benchmark,SS_benchmark,PP_benchmark,shadow_rate_benchmark,n1_benchmark,alpha1_tt_benchmark,beta1_tt_benchmark] =...
    counterfactual_function(simul_LB,simul_UB,n1,gain,CF_start,simul_type);

%descriptive statistics benchmark case
mean_benchmark= [mean(SS_benchmark(:,CF_start:end)')' ;
    mean(shadow_rate_benchmark(CF_start:end))];



%========================== 2D grid search for gain and n1
%================================================


simul_type = 4;

numSimul = 25 ; 
gain_grid = linspace(0,0.01,numSimul);
n1_grid = linspace(0,0.9,numSimul);

counter=0;
tic;

for jj=1:numSimul
disp(jj)
    parfor ii=1:numSimul
%         counter=counter+1;
%         disp(counter);

%     gain = gain_grid(jj);
	gain = gain_grid(jj);
    n1=n1_grid(ii);

[explosive_indicator,SS,PP,shadow_rate,n1,alpha1_tt,beta1_tt] =...
    counterfactual_function(simul_LB,simul_UB,n1,gain,CF_start,simul_type);

mean_simul_2d(jj,ii,:)= [mean(SS(:,CF_start:end)')' ;
    mean(shadow_rate(CF_start:end))];

 SS_all(:,:,jj,ii) = SS(:,CF_start:end)';

n1_simul(jj,ii,:) = n1(CF_start:end);
PP_simul(:,:,jj,ii) = PP(:,CF_start:end);
exp_ind_simul(jj,ii) = explosive_indicator;
    end

end
save counterfactual_experiments3_data.mat;
load counterfactual_experiments3_data.mat;






figure('Name','Output Gap Mean');
mesh(gain_grid,n1_grid,mean_simul_2d(:,:,1),'FaceColor','red','EdgeColor','interp');
% hold on;
% mesh(gain_grid,n1_grid,repmat(mean_benchmark(1),[numSimul numSimul 1]),'EdgeColor','none','FaceColor','black');
alpha 0.5;
grid off;
set(gca,'view',[62,38]);
xx=xlabel('\gamma');
yy=ylabel('n_t^L' ,'rotation',0);
yy.VerticalAlignment='cap';
xx.VerticalAlignment='cap';
zlabel('Average Output Gap, 09Q4-19Q4');
set(gca,'FontSize',14);
generate_figures('var1_CF2_fixedShocks_gap','figures'); 

% 
figure('Name','Inflation Mean');
mesh(gain_grid,n1_grid,pi_bar+mean_simul_2d(:,:,2),'FaceColor','red','EdgeColor','interp');
% hold on;
% mesh(gain_grid,n1_grid,repmat(mean_benchmark(2),[numSimul numSimul 1]),'EdgeColor','none','FaceColor','black');
alpha 0.5;
grid off;
set(gca,'view',[62,38]);
xx=xlabel('\gamma');
yy=ylabel('n_t^L' ,'rotation',0);
yy.VerticalAlignment='cap';
xx.VerticalAlignment='cap';
zlabel('Average Inflation, 09Q4-19Q4');
set(gca,'FontSize',14);
generate_figures('var1_CF2_fixedShocks_pi','figures'); 

figure('Name','Shadow Rate Mean');
mesh(gain_grid,n1_grid,(r_bar1-r_bar2)+mean_simul_2d(:,:,9),'FaceColor','red','EdgeColor','interp');
% hold on;
% mesh(gain_grid,n1_grid,repmat(mean_benchmark(9),[numSimul numSimul 1]),'EdgeColor','none','FaceColor','black');
alpha 0.5;
grid off;
set(gca,'view',[62,38]);
xx=xlabel('\gamma');
yy=ylabel('n_t^L' ,'rotation',0);
yy.VerticalAlignment='cap';
xx.VerticalAlignment='cap';
zlabel('Average Shadow Rate, 09Q4-19Q4');
set(gca,'FontSize',14);
generate_figures('var1_CF2_fixedShocks_SR','figures'); 